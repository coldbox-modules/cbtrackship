/**
 * The main client for cbtrackship
 */
component {
	
	// Settings
	property name="settings" inject="coldbox:modulesettings:cbtrackship";


	// Default constructor
	function init(){
		

		return this;
	}

	function onDIComplete() {
		
	}

	/**
	 * Delete a tracking record in TrackShip
	 * 
	 * @trackingNumber The tracking number
	 * @trackingProvider The tracking provider code (ups, fedex, etc)
	 * @orderId The internal order id
	 */
	function deleteTracking(
		required String trackingNumber,
		required String trackingProvider,
		required String orderID
	) {
		var body = {
				"tracking_number"     : trackingNumber,
				"tracking_provider"   : trackingProvider,
				"order_id"           : orderID
			};
			
		return hitAPI( "shipment/delete/", "post", body );
	}

	/**
	 * Create a tracking record in TrackShip
	 * 
	 * @trackingNumber The tracking number
	 * @trackingProvider The tracking provider code (ups, fedex, etc)
	 * @orderId The internal order id
	 * @postalCode The destination postal code
	 * @destinationCountry The destination country code
	 */
	function createTracking(
		required String trackingNumber,
		required String trackingProvider,
		required String orderID,
		String postalCode = "",
		String destinationCountry = ""
	) {
		var body = {
				"tracking_number"     : trackingNumber,
				"tracking_provider"   : trackingProvider,
				"order_id"           : orderId
			};

		if( len( postalCode ) ){
			body.postal_code = postalCode;
		}
		if( len( destinationCountry ) ){
			body.destination_country = destinationCountry;
		}

		return hitAPI( "shipment/create/", "post", body );
	}

	/**
	 * Get the status of a shipment.  You can pass either a tracking number and provider, or an order ID.
	 * 
	 * When using trackingNumber, the "data" key will be a struct for just that shipment.  
	 * When using orderID, the "data" key will be an array of all shipments associated with the order.
	 * 
	 * @trackingNumber The tracking number
	 * @trackingProvider The tracking provider code (ups, fedex, etc) (Mutex with orderid)
	 * @orderId The internal order id (Mutex with tracking number and provider)
	 * 
	 * @returns The shipment status structure.
	 */
	function getShipmentStatus( String trackingNumber="", String trackingProvider="", String orderID="" ) {4
		if( len( orderID ) ){
			var endpoint = "shipment/by-order-id/";
			var body = {
				"order_id" : orderID
			};
		} else if( len( trackingNumber ) && len( trackingProvider ) ) {
			var endpoint = "shipment/get/";
			var body = {
				"tracking_number"   : trackingNumber,
				"tracking_provider" : trackingProvider
			};
		} else {
			throw(
				type = "cbtrackship:TrackshipException",
				message = "You must provide either an orderID or both a trackingNumber and trackingProvider to get shipment status."
			);
		}
		return hitAPI( endpoint, "post", body );
	}

	/**
	 * Get all providers
	 */
	function getAllProviders() {
		return hitAPI( "shipping_carriers/supported", "get" );
	}

	/**
	 * Hit the TrackShip API
	 * 
	 * @endpoint The API endpoint to hit
	 * @method The HTTP method to use
	 * @body The body to send (for POST/PUT)
	 */
	private function hitAPI( String endpoint, String method="get", struct body={} ) {
		var local.result = "";

		cfhttp(
			url = "#settings.apiBaseUrl#/#endpoint#",
			method = method,
			result = "local.result"
		){
			cfhttpParam( type="header", name="Content-Type", value="application/json" );
			cfhttpParam( type="header", name="trackship-api-key", value="#settings.apiKey#" );
			cfhttpParam( type="header", name="app-name", value="#settings.appName#" );
			cfhttpParam( type="body", value=serializeJson( body ) );
		}

		// We're not going to check the status code here since throwing exceptions should be reserved for catastrophic issues that prevent the API from being reached.
		// Instead, so long as we get JSON back, we'll return it and allow the user to check it to see if the API call was successful.

		// verify response is JSON
		if( !isJson( local.result.fileContent ) ) {
			throw(
				type = "cbtrackship:TrackshipException",
				message = "Error hitting API: Invalid response from TrackShip - #local.result.fileContent#"
			);
		}

		var response = deserializeJson( local.result.fileContent );
		return response;
	}

}
