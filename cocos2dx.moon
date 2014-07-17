s = cc.Director\getInstance!\getWinSide!
layer1 = cc.LayerColor\create(cc.c4b(255,255,255,255),s.width,s.heigh/2)

layer1\setPosition(cc.p(0,s.heigh/2))

player = cc.sprite\create "1.png" , cc.rect(0,0,50,100)

layer1\addchild player

action = nil
random = math.random!
cclog "random= #{random}"
if (random < 0.20)
  action = cc.ScaleBy\create(3,2)
elseif (random < 0.40)
  action = cc.RotateBy\create(3,360)
elseif (random < 0.60)
  action = cc.Blink\create(1, 3)
elseif (random < 0.80)
  action = cc.TintBy\create(2, 0,-255,-255)
else
  action = cc.FadeOut\create(2)


