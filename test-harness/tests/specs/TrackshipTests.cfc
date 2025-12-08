component extends='coldbox.system.testing.BaseTestCase' appMapping='/root'{

/*********************************** LIFE CYCLE Methods ***********************************/

	this.unloadColdBox = true;
	this.testContainerName = "test-container-" & getTickCount();

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();		
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		
		describe( 'cbtrackship Module', () => {

			beforeEach(() => {
				setup();
			});

				it( 'can register library', () => {
					var trackshipClient = getLib();
					expect( trackshipClient ).toBeComponent();
				});

				it( 'can create a tracking', () => {
					var trackshipClient = getLib();
					var result = trackshipClient.createTracking(
						trackingNumber = "6860010537552",
						trackingProvider = "delhivery",
						orderID = "test-order-12345",
						postalCode = "98012",
						destinationCountry = "US"
					);

				//	writedump( result );
					// verify these results {"status":"ok","status_msg":"pending_trackship","trackers_balance":999,"user_plan":"Large","period":"month"}
					expect( result.status ).toBe( "ok" );
					expect( result.status_msg ).toBe( "pending_trackship" );
					expect( result ).toHaveKey( "trackers_balance" );
					expect( result ).toHaveKey( "user_plan" );
					expect( result ).toHaveKey( "period" );

				});				

				it( 'can get a shipment status by tracking number and provider', () => {
					var trackshipClient = getLib();
					var result = trackshipClient.getShipmentStatus(
						trackingNumber = "6860010537552",
						trackingProvider = "delhivery"
					);

				//	writedump( result );
				});

				it( 'can get a shipment status by order ID', () => {
					var trackshipClient = getLib();
					var result = trackshipClient.getShipmentStatus(
						orderID = "test-order-12345"
					);

				//	writedump( result );
				});

				it( 'can delete a tracking', () => {
					var trackshipClient = getLib();
					var result = trackshipClient.deleteTracking(
						trackingNumber = "6860010537552",
						trackingProvider = "delhivery",
						orderID = "test-order-12345"
					);

				//	writedump( result );
				});

			
				it( 'can get providers', () => {
					var trackshipClient = getLib();
					var result = trackshipClient.getAllProviders();
					expect( result ).toBeStruct();

					//writedump( result );
				});

				
				

		});
	}

	private function getLib( name='client@cbtrackship' ){
		return getWireBox().getInstance( name );
	}

}