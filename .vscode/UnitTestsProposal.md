# Unit Tests Proposal - LocationController & LocationModel

**Module:** Schedule/Location Management  
**Date:** 2026-01-08  
**Status:** Ready for Implementation  

---

## Overview

Unit tests for SCHEDULE_LOCATION endpoints. These tests validate CRUD operations, business logic, and data integrity for location management (physical and virtual meeting places).

---

## API Endpoints

### Base Path
```
/location
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/getalllocations` | Get all active locations (ordered by DS_LOCATION) |
| GET | `/getlocationsbytype` | Get active locations filtered by type (F=Physical, V=Virtual) |
| GET | `/getonelocation` | Get single location by ID_LOCATION |
| POST | `/insertlocation` | Create new location |
| PUT | `/updatelocation` | Update existing location |
| DELETE | `/deletelocation` | Soft-delete location (ST='C') |

---

## Test Cases

### 1. GetAllLocations

**Purpose:** Retrieve all active locations

**Request:**
```json
GET /location/getalllocations
Content-Type: application/json

{}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "data": [
    {
      "ID_LOCATION": 1,
      "DS_LOCATION": "Sala A",
      "TYPE_LOCATION": "F",
      "ADDRESS_TEXT": "Calle Principal 123",
      "VIRTUAL_URL": "",
      "LATITUDE": 40.4168,
      "LONGITUDE": -3.7038,
      "NOTES": "First floor",
      "ST": "A",
      "CREATED_AT": "2026-01-08T10:00:00Z",
      "UPDATED_AT": "2026-01-08T10:00:00Z"
    },
    {
      "ID_LOCATION": 2,
      "DS_LOCATION": "Zoom Reunión",
      "TYPE_LOCATION": "V",
      "ADDRESS_TEXT": "",
      "VIRTUAL_URL": "https://zoom.us/j/123456789",
      "LATITUDE": null,
      "LONGITUDE": null,
      "NOTES": "Default meeting room",
      "ST": "A",
      "CREATED_AT": "2026-01-08T11:00:00Z",
      "UPDATED_AT": "2026-01-08T11:00:00Z"
    }
  ]
}
```

**Test Validations:**
- ✅ Returns array of locations
- ✅ Only includes ST='A' (active)
- ✅ Ordered by DS_LOCATION alphabetically
- ✅ All fields present and correct type
- ✅ Empty array when no active locations exist

---

### 2. GetLocationsByType

**Purpose:** Filter locations by type (Physical or Virtual)

**Request (Physical Locations):**
```json
GET /location/getlocationsbytype
Content-Type: application/json

{
  "TYPE_LOCATION": "F"
}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "data": [
    {
      "ID_LOCATION": 1,
      "DS_LOCATION": "Sala A",
      "TYPE_LOCATION": "F",
      "ADDRESS_TEXT": "Calle Principal 123",
      "VIRTUAL_URL": "",
      "LATITUDE": 40.4168,
      "LONGITUDE": -3.7038,
      "NOTES": "First floor",
      "ST": "A",
      "CREATED_AT": "2026-01-08T10:00:00Z",
      "UPDATED_AT": "2026-01-08T10:00:00Z"
    }
  ]
}
```

**Test Cases:**
- ✅ Filter by TYPE_LOCATION='F' (Physical)
- ✅ Filter by TYPE_LOCATION='V' (Virtual)
- ✅ Only active locations returned
- ✅ Ordered by DS_LOCATION
- ✅ Empty array when no matches
- ❌ Invalid TYPE_LOCATION → Error (not F or V)
- ❌ Missing TYPE_LOCATION parameter → Error (required)

---

### 3. GetOneLocation

**Purpose:** Retrieve single location by ID

**Request:**
```json
GET /location/getonelocation
Content-Type: application/json

{
  "ID_LOCATION": 1
}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "data": [
    {
      "ID_LOCATION": 1,
      "DS_LOCATION": "Sala A",
      "TYPE_LOCATION": "F",
      "ADDRESS_TEXT": "Calle Principal 123",
      "VIRTUAL_URL": "",
      "LATITUDE": 40.4168,
      "LONGITUDE": -3.7038,
      "NOTES": "First floor",
      "ST": "A",
      "CREATED_AT": "2026-01-08T10:00:00Z",
      "UPDATED_AT": "2026-01-08T10:00:00Z"
    }
  ]
}
```

**Test Cases:**
- ✅ Returns array with single location
- ✅ Only returns ST='A' (active)
- ✅ Returns null if location doesn't exist
- ✅ Returns null if location is deleted (ST='C')
- ❌ Missing ID_LOCATION → Error (required)
- ❌ Invalid ID_LOCATION (not numeric) → Error

---

### 4. InsertLocation

**Purpose:** Create new location with validation

**Request (Physical Location):**
```json
POST /location/insertlocation
Content-Type: application/json

{
  "DS_LOCATION": "Auditorio Principal",
  "TYPE_LOCATION": "F",
  "ADDRESS_TEXT": "Edificio Norte, 5º Piso",
  "VIRTUAL_URL": "",
  "LATITUDE": 40.4168,
  "LONGITUDE": -3.7038,
  "NOTES": "Capacity: 100 persons"
}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "integer": 3,
  "message": "Location created successfully"
}
```

**Request (Virtual Location):**
```json
POST /location/insertlocation
Content-Type: application/json

{
  "DS_LOCATION": "Teams Meeting",
  "TYPE_LOCATION": "V",
  "ADDRESS_TEXT": "",
  "VIRTUAL_URL": "https://teams.microsoft.com/l/meetup-join/...",
  "LATITUDE": null,
  "LONGITUDE": null,
  "NOTES": "Default Microsoft Teams channel"
}
```

**Test Cases:**
- ✅ Create physical location (F) with ADDRESS_TEXT
- ✅ Create virtual location (V) with VIRTUAL_URL
- ✅ Optional fields (ADDRESS_TEXT, VIRTUAL_URL, NOTES) can be empty
- ✅ Optional fields (LATITUDE, LONGITUDE) can be null or 0
- ✅ Returns new ID_LOCATION
- ✅ Location created with ST='A' (active)
- ❌ Duplicate DS_LOCATION when active exists → Error: "Active location with this name already exists"
- ❌ TYPE_LOCATION not F or V → Error: "TYPE_LOCATION must be F (Physical) or V (Virtual)"
- ❌ Missing DS_LOCATION → Error (required)
- ❌ Missing TYPE_LOCATION → Error (required)
- ✅ Same name allowed after previous soft-delete (ST='C')

**Data Validation:**
```
Field          | Type   | Required | Rules
DS_LOCATION    | String | Yes      | Max 150 chars, unique when active
TYPE_LOCATION  | String | Yes      | Must be 'F' or 'V'
ADDRESS_TEXT   | String | No       | Max 250 chars
VIRTUAL_URL    | String | No       | Max 500 chars
LATITUDE       | Double | No       | Range -90 to 90
LONGITUDE      | Double | No       | Range -180 to 180
NOTES          | Text   | No       | Unlimited
```

---

### 5. UpdateLocation

**Purpose:** Modify existing location

**Request:**
```json
PUT /location/updatelocation
Content-Type: application/json

{
  "ID_LOCATION": 1,
  "DS_LOCATION": "Sala A - Actualizada",
  "TYPE_LOCATION": "F",
  "ADDRESS_TEXT": "Calle Principal 123, Piso 2",
  "VIRTUAL_URL": "",
  "LATITUDE": 40.4170,
  "LONGITUDE": -3.7040,
  "NOTES": "Renovated in 2025"
}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "message": "Location updated successfully"
}
```

**Test Cases:**
- ✅ Update active location (ST='A')
- ✅ Update multiple fields simultaneously
- ✅ Update partial fields
- ✅ Returns success=true when updated
- ✅ Returns success=false when location not found
- ✅ Returns success=false when location is deleted (ST='C')
- ❌ TYPE_LOCATION not F or V → Error
- ❌ Missing ID_LOCATION → Error (required)
- ❌ Missing DS_LOCATION → Error (required)
- ❌ Missing TYPE_LOCATION → Error (required)
- ✅ Cannot update deleted location (ST='C')

---

### 6. DeleteLocation

**Purpose:** Soft-delete location (mark as cancelled)

**Request:**
```json
DELETE /location/deletelocation
Content-Type: application/json

{
  "ID_LOCATION": 1
}
```

**Expected Response (HTTP 200):**
```json
{
  "success": true,
  "message": "Location deleted successfully"
}
```

**Test Cases:**
- ✅ Soft-delete active location (ST='A' → ST='C')
- ✅ Returns success=true when deleted
- ✅ Returns success=false when location already deleted
- ✅ Returns success=false when location not found
- ✅ Deleted location no longer appears in GetAllLocations
- ✅ Allows creating new location with same DS_LOCATION after delete
- ❌ Missing ID_LOCATION → Error (required)

---

## Edge Cases & Business Logic

### Soft-Delete Strategy
**Rule:** Allow multiple locations with same name, but only ONE can be active

**Test Scenario:**
```
1. Create "Sala A" (ST='A')
2. Try to create "Sala A" again → Error: "Active location with this name already exists"
3. Delete first "Sala A" (ST='C')
4. Create "Sala A" again (new ST='A') → SUCCESS
```

### Type Validation
**Rule:** Only accept TYPE_LOCATION = 'F' or 'V'

**Test Cases:**
- ✅ 'F' (Physical) - accepted
- ✅ 'V' (Virtual) - accepted
- ❌ 'X' - rejected
- ❌ 'f' (lowercase) - rejected (case-sensitive)
- ❌ Empty string - rejected
- ❌ null - rejected

### Coordinates Validation
**Rule:** LATITUDE and LONGITUDE are optional but must be within valid ranges if provided

**Test Cases:**
- ✅ Both null/0 for virtual locations
- ✅ Valid: LATITUDE=40.4168, LONGITUDE=-3.7038
- ✅ Valid: LATITUDE=-33.8688, LONGITUDE=151.2093 (negative values)
- ❌ LATITUDE=91 (out of range -90 to 90)
- ❌ LONGITUDE=181 (out of range -180 to 180)

### Timestamp Behavior
**Rule:** CREATED_AT set on insert, UPDATED_AT updated on modify

**Test Cases:**
- ✅ CREATED_AT = insertion time
- ✅ UPDATED_AT = insertion time (initially)
- ✅ UPDATED_AT changes on update
- ✅ CREATED_AT remains unchanged after update

---

## Response Format

### Success Response
```json
{
  "success": true,
  "data": [...],          // For GET operations
  "integer": 123,         // For POST operations (new ID)
  "message": "..."        // Description
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "code": 400             // HTTP status code
}
```

---

## Test Execution Checklist

### Phase 1: Happy Path (All should pass)
- [ ] GetAllLocations with data
- [ ] GetLocationsByType = 'F'
- [ ] GetLocationsByType = 'V'
- [ ] GetOneLocation (existing)
- [ ] InsertLocation (Physical)
- [ ] InsertLocation (Virtual)
- [ ] UpdateLocation (all fields)
- [ ] DeleteLocation (soft-delete)

### Phase 2: Edge Cases & Validation
- [ ] Duplicate DS_LOCATION prevention
- [ ] TYPE_LOCATION validation (F/V only)
- [ ] Coordinates validation
- [ ] Soft-delete recovery
- [ ] GetOneLocation (non-existent)
- [ ] GetOneLocation (deleted)
- [ ] Update deleted location
- [ ] Delete already-deleted location

### Phase 3: Error Handling
- [ ] Missing required parameters
- [ ] Invalid data types
- [ ] Out-of-range values
- [ ] Empty strings when not allowed
- [ ] Duplicate operation detection

---

## Test Data Fixtures

### Fixture 1: Physical Location
```json
{
  "DS_LOCATION": "Sala de Reuniones A",
  "TYPE_LOCATION": "F",
  "ADDRESS_TEXT": "Av. Paseo de la Castellana 44, Madrid",
  "VIRTUAL_URL": "",
  "LATITUDE": 40.4534,
  "LONGITUDE": -3.6885,
  "NOTES": "Second floor, capacity for 20 people"
}
```

### Fixture 2: Virtual Location
```json
{
  "DS_LOCATION": "Zoom Default Meeting",
  "TYPE_LOCATION": "V",
  "ADDRESS_TEXT": "",
  "VIRTUAL_URL": "https://zoom.us/j/91234567890",
  "LATITUDE": null,
  "LONGITUDE": null,
  "NOTES": "Default Zoom room for all virtual meetings"
}
```

### Fixture 3: Minimal Physical Location
```json
{
  "DS_LOCATION": "Oficina",
  "TYPE_LOCATION": "F",
  "ADDRESS_TEXT": "",
  "VIRTUAL_URL": "",
  "LATITUDE": 0,
  "LONGITUDE": 0,
  "NOTES": ""
}
```

---

## Notes for Test Implementation

1. **Database State:** Ensure clean test data between test runs. Use transactions or rollback.
2. **Timestamps:** Compare timestamps with tolerance (±1 second) due to DB precision.
3. **Coordinates:** Test with both positive and negative values for latitude/longitude.
4. **Soft Delete:** Verify deleted locations don't appear in any GET operations except explicit deleted-record queries.
5. **Concurrency:** Test multiple inserts with same name simultaneously (should fail one).
6. **Performance:** GetAllLocations with 1000+ records should respond < 1 second.

---

**Status:** Ready for implementation  
**Last Updated:** 2026-01-08
