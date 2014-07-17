class Birds
  yo: "I can fly !"
  new: =>
    @yo = {}

class Fish
  yo: "I can swim !"
  new: =>
    @yo = {""}

class CatFish extends Fish
  say: =>
    print item for item in *@yo

cf = CatFish!
cf\say!
