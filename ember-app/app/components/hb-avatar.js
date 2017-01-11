import Ember from 'ember';

var HbAvatarComponent = Ember.Component.extend({
   tagName: 'img',
 
  classNames: 'img-responsive',
  attributeBindings: ["src", "title", "width", "height"],
  
  width: 24,
  
  height: 24,
 
  service: 'gravatar',
  title: "",
  src: function() {
    return this[this.get('service')+'Url']();
  }.property('service', 'user'),
 
  gravatarUrl: function() {
    return this.get("user.avatar_url") ?
             this.get("user.avatar_url")
          :  'https://secure.gravatar.com/avatar/' + this.get("user") + '?s='+ this.get("width") +'&d=retro';
  }
});

export default HbAvatarComponent;
