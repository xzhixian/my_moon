class Birds
  yo: "I can fly !"
  new: =>
    @yo = {}
    
class Fish
  yo: "I can swim !"
  new: =>
    @yo = {}
    
class CatFish extends Fish
  yo: super @yo
  say: ->
    print yo
    
cf = CatFish!
cf\say!