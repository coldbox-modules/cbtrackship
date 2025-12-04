component {

	// Module Properties
	this.title          = "cbtrackship";
	this.author         = "Brad Wood";
	this.description    = "A utility to integrate with TrackShip"
	this.modelNamespace = "cbtrackship";
	this.cfmapping      = "cbtrackship";

	/**
	 * Module Config
	 */
	function configure(){
		variables.settings = {
			apiBaseUrl = "https://api.trackship.com/v1",
			apiKey     = "",
			appName	= ""
		}
	}

}
