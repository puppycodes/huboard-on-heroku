import Ember from 'ember';

var SettingsRoute = Ember.Route.extend({
  model: function(){
    // hacks!
    var appModel = this.modelFor("application");
    return appModel;

  }
});

export default SettingsRoute;
