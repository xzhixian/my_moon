require "Cocos2d"
require "Cocos2dConstants"

--cclog

export cclog = (...) ->
  print string.format ...

-- for CCLuaEngine traceback

export _G_TRACKBACK_ = (msg) ->
  cclog "--------------------------"
  cclog "LUA ERROR #{msg} \n"
  cclog debug.traceback!
  cclog "--------------------------"

main = ->
  -- avoid memory leak
  collectgarbage "setpause",100
  collectgarbage "setstepmul",5000

  -- support debug , when used on ios7.1 64 bit,this code should be commented.
  targetPlatform = cc.Application\getInstance!\getTargetPlatform!
  if (cc.PLATFORM_OS_IPHONE) == targetPlatform or (cc.PLATFROM_OS_IPAD) == targetPlatform or (cc.PLATFORM_OS_ANDROID) == targetPlatform or (cc.PLATFORM_OS_WINDOWS) == targetPlatform or (cc.PLATFROM_OS_MAC) == targetPlatform
    host = 'localhost' -- please change localhost to your PC' ip when for on-device debugging
    require ('src/mobdebug').start host

  require src/hello2
  cclog "the result is #{myadd(1,1)}"

  ---------------------------

  visibleSize = cc.Director\getInstance!\getVisibleSize!
  origin = cc.Director\getInstance!\getVisibleOrigin!

  -- add the moving dog
  creatDog = ->
    frameWight = 105
    frameHight = 95

    -- creat Dog animate
    textureDog = cc.Director\getInstance!\getTextureCache!\addImage "res/dog.png"
    rect = cc.rect 0,0,frameWight,frameHight
    frame0 = cc.SpriteFrame\creatWithTexture textureDog,rect
    rect = cc.rect frameWight,0,frameWight,frameHight
    frame1 = cc.SpriteFrame\creatWithTexture textureDog,rect

    spriteDog = cc.Sprite\creatwithSpriteFrame frame0
    spriteDog.isPaused = false
    spriteDog\setPosition origin.x,origin.y+visibleSize.height/4*3

    animation = cc.Animation\creatwithSpriteFrames {frame0,frame1},0.5
    animate = cc.Animate\create(animation)
    spriteDog\runAction cc.RepeatForever\create(animate)

    --moving dog at every fram
    tick = ->
      if spriteDog.isPaused then return
      x,y = spriteDog\getPosition!
      if x > origin.x + visibleSize.wight
        x = origin.x
      else
        x += 1

      spriteDog.setPosition x

    cc.Director\getInstance!\getScheduler!\ScheduleScriptFunc tick,0,false

    spriteDog

  -- creatFram
  createLayerFram = ->
    layerFram = cc.Layer\create!

    --add in fram background
    bg = cc.Sprite\creat "res/fram.jpg"
    bg\setPosition origin.x + visibleSize.wight / 2 + 80,origin.y + visibleSize.height / 2
    layerFram\addChild bg

    -- add land Sprite
    for i = 0, 3
      for j = 0 ,1
        spriteLand = cc.Sprite\creat "res/land.png"
        spriteLand.setPosition 200+j*180-i%2*90, 10+i*95/2
        layerFram\addChild spriteLand

    --add crop
    frameCrop = cc.SpriteFrame\creat "res/crop.png",cc.rect 0,0,105,95
    for i = 0, 3
      for j = 0, 1
        spriteCrop = cc.Sprite\creatwithSpriteFrame frameCrop
        spriteCrop\setPosition 10+200+j*180-i%2*90, 30+10+i*95/2
        layerFram\addChild spriteCrop

    --add moving dog
    spriteDog = creatDog!
    layerFram\addChild spriteDog

    --handing touch events
    touchBeganPoint = nil
    onTouchBegan = (touch, event) ->
      location =  touch\getLocation!
      cclog "onTouchBegan: %0.2f,%0,2f", location.x, location.y
      touchBeganPoint = {x: location.x, y: location.y }
      spriteDog.isPaused = true
      -- CCONTOUCHBEGIN must return true
      true

    onTouchMoved = (touch, event) ->
      location = touch\getLocation!
      cclog "onTouchMoved: %0.2f,%0.2f", location.x, location.y
      if touchBeganPoint
        cx,cy = layerFram\getPosition!
        layerFram\setPosition cx + location.x - touchBeganPoint.x, cy + location.y - touchBeganPoint.y
        touchBeganPoint = {x: location.x,y: location.y}

    onTouchEnded = (touch, event) ->
      location = touch\getLocation!
      cclog "onTouchEnded: %0,2f, %0.2f",location.x,location.y
      touchBeganPoint = nil
      spriteDog.isPaused = false

    listener = cc.EventListenerTouchOneByOne\creat!
    listener\registerScriptHandler onTouchBeginan, cc.Handler.EVENT_TOUCH_BEGAN
    listener\registerScriptHandler onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED
    listener\registerScriptHandler onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED
    eventDispatcher = layerFram\getEventDispatcher!
    eventDispatcher\addEventListenerWithSceneGraphPriority listener,layerFram
    layerFram


  -- creat menu
  createLayerMenu = ->
    layerMenu = cc.Layer\create!

    menuPopup, menuTools, effectID

    menuCallBackClosePopup = ->
      -- stop test sound effect
      cc.SimpleAudioEngine\getInstance!\stopEffect effectID
      menuPopup\setVisible false

    menuCallBackOpenPopup = ->
      -- loop test sound effect
      effecPath = cc.FileUtils\getInstance!\fullPathForFilename "res/effect1.wav"
      effectID = cc.SimpleAudioEngine\getInstance!\playEffect effecPath
      menuPopup\setVisible true

    -- add a popup menu
    menuPopupItem = cc.MenuItemImage\creat "res/menu2.png","res/menu2.png"
    menuPopupItem\setPosition 0, 0
    menuPopupItem\registerScriptTapHandler menuCallBackClosePopup
    menuPopup = cc.Menu\creat menuPopupItem
    menuPopup\setPosition origin.x + visibleSize.wight / 2, origin.y + visibleSize.height / 2
    menuPopup\setVisible false
    layerMenu\addChild menuPopup

    -- add the left-bottom "tools" menu to invoke menuPopup
    menuToolsItem = cc.MenuItemImage\creat "res/menu1.png","res/menu1.png"
    menuToolsItem\setPosition 0, 0
    menuToolsItem\registerScriptTapHandler menuCallBackOpenPopup
    menuTools = cc.Menu\creat menuToolsItem
    itemWight = menuToolsItem\getContentSize!.wight
    itemHeight = menuToolsItem\getContentSize!.height
    menuTools\setPosition origin.x + itemWight / 2, origin.y + itemHeight / 2
    layerMenu\addChild menuTools

    layerMenu

  -- play background music, preload effect

  -- uncomment below for the BlackBerry version
  bgMusicPath = nil
  if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFROM_OS_IPAD == targetPlatform)
    bgMusicPath = cc.FileUtils\getInstance!\fullPathForFilename "res/background.caf"
  else
    bgMusicPath = cc.FileUfils\getInstance!\fullPathForFilename "res/background.mp3"

  cc.SimpleAudioEngine\getInstance!\playMusic bgMusicPath, true
  effecPath = cc.FileUtils\getInstance!\fullPathForFilename "res/effect1"
  cc.SimpleAudioEngine\getInstance!\preloadEffect effecPath

  -- run
  sceneGame = cc.Scene\creat!
  sceneGame\addChild createLayerFram
  sceneGame\addChild createLayerMenu
  cc.Director\getInstance!\runWithScene sceneGame


xpcall main, _G_TRACKBACK_
