# cbtrackship

A ColdBox module for integrating with the [TrackShip](https://trackship.com/) shipment tracking API. Track packages across multiple carriers including FedEx, UPS, Delhivery, and many more.

## Installation

Install via CommandBox:

```bash
box install cbtrackship
```

## Configuration

Configure the module in your ColdBox application's `config/Coldbox.cfc` file using the `moduleSettings` structure:

```js
moduleSettings = {
    cbtrackship = {
        // Your TrackShip API key (required)
        apiKey = "your-api-key-here",
        
        // Your application name for identification (required)
        appName = "your-app-name",
        
        // API Base URL (optional - defaults to TrackShip's production API)
        apiBaseUrl = "https://api.trackship.com/v1"
    }
};
```

### Settings Reference

| Setting | Type | Required | Default | Description |
|---------|------|----------|---------|-------------|
| `apiKey` | String | Yes | `""` | Your TrackShip API key. Obtain this from your TrackShip dashboard. |
| `appName` | String | Yes | `""` | The name of your application. Used for identification in API requests. |
| `apiBaseUrl` | String | No | `https://api.trackship.com/v1` | The base URL for the TrackShip API. Override for testing or custom endpoints. |

### Environment Variables

You can use environment variables to configure the module (recommended for production):

```js
moduleSettings = {
    cbtrackship = {
        apiKey = getSystemSetting( "TRACKSHIP_API_KEY", "" ),
        appName = getSystemSetting( "TRACKSHIP_APP_NAME", "" )
    }
};
```

## Usage

Inject the TrackShip client into your handlers or models:

```js
// Inject via property
property name="trackshipClient" inject="client@cbtrackship";

// Or via WireBox
var trackshipClient = getInstance( "client@cbtrackship" );
```

## API Methods

### createTracking()

Create a new tracking record in TrackShip to begin monitoring a shipment.

```js
var result = trackshipClient.createTracking(
    trackingNumber = "1Z999AA10123456784",
    trackingProvider = "ups",
    orderID = "order-12345",
    postalCode = "98012",           // optional
    destinationCountry = "US"       // optional
);
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `trackingNumber` | String | Yes | The carrier tracking number for the shipment. |
| `trackingProvider` | String | Yes | The carrier code (e.g., `ups`, `fedex`, `delhivery`, etc.). |
| `orderID` | String | Yes | Your internal order ID to associate with this tracking. |
| `postalCode` | String | No | The destination postal/zip code. Helps improve tracking accuracy. |
| `destinationCountry` | String | No | The destination country code (e.g., `US`, `CA`, `UK`). |

#### Response

```js
{
    "status": "ok",
    "status_msg": "pending_trackship",
    "trackers_balance": 999,
    "user_plan": "Large",
    "period": "month"
}
```

---

### getShipmentStatus()

Get the current status of a shipment. You can query by either tracking number/provider OR by order ID.

#### By Tracking Number and Provider

```js
var result = trackshipClient.getShipmentStatus(
    trackingNumber = "1Z999AA10123456784",
    trackingProvider = "ups"
);
```

When using `trackingNumber` and `trackingProvider`, the `data` key in the response will be a **struct** containing the shipment details.

#### By Order ID

```js
var result = trackshipClient.getShipmentStatus(
    orderID = "order-12345"
);
```

When using `orderID`, the `data` key in the response will be an **array** of all shipments associated with that order.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `trackingNumber` | String | Conditional | The carrier tracking number. Required if not using `orderID`. |
| `trackingProvider` | String | Conditional | The carrier code. Required if using `trackingNumber`. |
| `orderID` | String | Conditional | Your internal order ID. Required if not using tracking number/provider. |

> **Note:** You must provide either `orderID` OR both `trackingNumber` and `trackingProvider`. These are mutually exclusive query methods.

---

### deleteTracking()

Delete a tracking record from TrackShip.

```js
var result = trackshipClient.deleteTracking(
    trackingNumber = "1Z999AA10123456784",
    trackingProvider = "ups",
    orderID = "order-12345"
);
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `trackingNumber` | String | Yes | The carrier tracking number for the shipment. |
| `trackingProvider` | String | Yes | The carrier code (e.g., `ups`, `fedex`, `delhivery`, etc.). |
| `orderID` | String | Yes | Your internal order ID associated with this tracking. |

---

### getAllProviders()

Retrieve a list of all supported shipping carriers/providers from TrackShip.

```js
var result = trackshipClient.getAllProviders();
```

#### Parameters

This method takes no parameters.

#### Response

Returns an array of supported shipping carriers with their details.

---

## Supported Carriers

TrackShip supports numerous carriers worldwide. Some common provider codes include:

- `ups` - UPS
- `fedex` - FedEx
- `usps` - USPS
- `dhl` - DHL
- `delhivery` - Delhivery

For a complete list of supported carriers, refer to the [TrackShip documentation](https://docs.trackship.com/).

## Error Handling

The client will throw exceptions of type `cbtrackship:TrackshipException` in the following cases:

1. **Invalid API response** - When the API returns non-JSON content
2. **Missing parameters** - When calling `getShipmentStatus()` without proper parameters

API-level errors (such as invalid tracking numbers or authentication failures) are returned in the response structure rather than thrown as exceptions, allowing you to handle them gracefully:

```js
var result = trackshipClient.createTracking(
    trackingNumber = "invalid",
    trackingProvider = "ups",
    orderID = "order-123"
);

if( result.status != "ok" ) {
    // Handle the error
    log.error( "TrackShip error: #result.status_msg#" );
}
```

## License

See [LICENSE.txt](license.txt)

