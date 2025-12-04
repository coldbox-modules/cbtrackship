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

				it( 'should register library', () => {
					var cbtrackship = getLib();
					expect( cbtrackship ).toBeComponent();
				});

		});
	}

	private function getLib( name='client@cbtrackship' ){
		return getWireBox().getInstance( name );
	}

}