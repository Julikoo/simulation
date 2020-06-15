;;; Helpers
globals [steps maxMarketX maxMarketY catSizeX catSizeY maxItemsPerCat spawnX spawnY]

;;; Categories
breed [shortItems shortItem]
breed [middleItems middleItem]
breed [longItems longItem]

;;; Actual Best-Before-Date as a increasing/decreasing number and the maximum Best-Before-Date
shortItems-own [bbd bbdm]
middleItems-own [bbd bbdm]
longItems-own [bbd bbdm]

;;; Buyers
breed [buyers buyer]
buyers-own [
  groceryneedLong
  groceryneedMiddle
  groceryneedShort
]

to setup
  ;;; Resets
  ca
  reset-ticks
  ;;; Set patch color for market space
  ask patches with [pycor > -10] [set pcolor blue]
  ;;; init helpers
  set steps 1
  set spawnX -23
  set spawnY 23

  ;;; Create all shortItems
  spawnFirstShortItem
  getMarketSize
  getShortItems
  ;;; Create all MiddleItems
  spawnFirstMiddleItem
  getMiddleItems
  ;;; Create all LongItems
  spawnFirstLongItem
  getLongItems
  ;;; Assign colors for all Items according to best before date
  checkBbdColor
end

;;; Create buyers and let them buy items according to their behaviour
to go
  ask buyers [die]
  eachDay
  checkBbdColor
  setup-Buyers
  tick
end

;;; Create set of Buyers
to setup-Buyers
  create-buyers random 5
  [
    set shape "person"
    set color white
    set size 2
    setxy random-xcor -20
  ]
  create-groceryneed
end

;;; Assign value for each Category, reflecting the need of an item within this Category
to create-groceryneed
  ask buyers [
    set groceryneedLong longInput
    buyLong groceryneedLong
    set groceryneedMiddle middleInput
    buyMiddle groceryneedMiddle
    set groceryneedShort longInput
    buyShort groceryneedShort
  ]
end

;;; Assign for each category how many days(q) an Item needs to be still good from it's current best before date, so a buyer might still buy it(Adjusted with Sliders)
to buyLong [q]
  ask longItems with [bbd >= longInput] [
    if q != 0
    [
      set color white
      set bbd -1
      set q (q - 1)
    ]
  ]
end

to buyMiddle [q]
  ask middleItems with [bbd >= middleInput] [
    if q != 0
    [set color white
      set bbd -1
      set q (q - 1)
    ]
  ]
end

to buyShort [q]
  ask shortItems with [bbd >= shortInput] [
    if q != 0
    [set color white
      set bbd -1
      set q (q - 1)
    ]
  ]
end

;;; Check for displaying correct color according to bbd value to bbdm value
to checkBbdColor
  ask shortItems [if bbd = 0 [set color black]]
  ask shortItems [if ( bbd > 0 ) and ( bbd <= bbdm * 0.5 ) [set color orange]]
  ask shortItems [if bbd > bbdm * 0.5 [set color green]]

  ask middleItems [if bbd = 0 [set color black]]
  ask middleItems [if ( bbd > 0 ) and ( bbd <= bbdm * 0.5 ) [set color orange]]
  ask middleItems [if bbd > bbdm * 0.5 [set color green]]

  ask longItems [if bbd = 0 [set color black]]
  ask longItems [if ( bbd > 0 ) and ( bbd <= bbdm * 0.2 ) [set color orange]]
  ask longItems [if bbd > bbdm * 0.2 [set color green]]
end

;;; bbd goes down by 1
to eachDay
  ask shortItems with [ bbd > 0 ] [ set bbd bbd - 1 ]
  ask middleItems with [ bbd > 0 ] [ set bbd bbd - 1 ]
  ask longItems with [ bbd > 0 ] [ set bbd bbd - 1 ]
end
  ;;; Get Market size, partly dynamic function to calcutate a field for market with max possible width for those patches
to getMarketSize

  set maxMarketX max [pxcor] of patches with [pcolor = blue]
  ;show maxMarketX
  set maxMarketY min [pycor] of patches with [pcolor = blue]
  ;show maxMarketY
  set catSizeX floor ( ( ( ( 25 + abs maxMarketX ) - 2 * 2 ) / 3 ) / [size] of shortItem 0 )
  ;show catSizeX
  set catSizeY floor ( ( ( 25 + abs maxMarketY  ) - 2 * 2 ) / [size] of shortItem 0 )
  ;show catSizeY
  ;;; Calculate max possible amount of Items per Category without overlapping icons
  set maxItemsPerCat catSizeX * catSizeY


end

;;; Further shortItems
to getShortItems
  set spawnY ( 23 - 2 )

  ask shortItems [
    while [ steps < allCat ] [
      hatch-shortItems 1 [
        if spawnY <= maxMarketY [ set spawnX ( spawnX + 2 ) set spawnY 23 ]
        setxy spawnX spawnY
        set bbd ( bbdm - random 5 )
      ]
      set steps ( steps + 1 )
      set spawnY ( spawnY - 2 )
    ]
  ]

end

;;; Further middleItems
to getMiddleItems
  set steps 1
  set spawnX ( -23 + 8 * 2 )
  set spawnY ( 23 - 2 )

  ask middleItems [
    while [ steps < allCat ] [
      hatch-middleItems 1 [
        if spawnY <= maxMarketY [ set spawnX ( spawnX + 2 ) set spawnY 23 ]
        setxy spawnX spawnY
        set bbd ( bbdm - random 10 )
      ]
      set steps ( steps + 1 )
      set spawnY ( spawnY - 2 )
    ]
  ]

end

;;; Further longItems
to getLongItems
  set steps 1
  set spawnX ( -23 + 8 * 4 )
  set spawnY ( 23 - 2 )

  ask longItems [
    while [ steps < allCat ] [
      hatch-longItems 1 [
        if spawnY <= maxMarketY [ set spawnX ( spawnX + 2 ) set spawnY 23 ]
        setxy spawnX spawnY
        set bbd ( 30 + (random 30) * 4 )
      ]
      set steps ( steps + 1 )
      set spawnY ( spawnY - 2 )
    ]
  ]

end

;;; Create First items
to spawnFirstShortItem
  ;;; First shortItem
  create-shortItems 1
  ask shortItem 0 [
    set shape "cow"
    set size 2
    set bbdm 7
    set bbd ( bbdm - random 5 )
    set heading 0
    setxy spawnX spawnY
  ]
end

to spawnFirstMiddleItem
  ;;; First middleItem
  create-middleItems 1
  ask middleItem allCat [
    set shape "cheese"
    set size 2
    set bbdm 14
    set bbd ( bbdm - random 10 )
    set heading 0
    setxy ( -23 + 8 * 2 ) 23
  ]
end

to spawnFirstLongItem
  ;;; First longItem
  create-longItems 1
  ask longItem ( allCat * 2 ) [
    set shape "flatBox"
    set size 2
    set bbdm 151
    set bbd ( 30 + (random 30) * 4 )
    set heading 0
    setxy ( -23 + 8 * 4 ) 23
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
132
28
803
700
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
28
33
101
66
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
32
103
95
136
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
837
31
1037
181
plot
time
ressources
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

SLIDER
841
248
1013
281
longInput
longInput
0
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
842
346
1014
379
middleInput
middleInput
0
5
1.0
1
1
NIL
HORIZONTAL

SLIDER
848
462
1020
495
shortInput
shortInput
0
3
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
839
193
1012
249
Wie lange müssen Lebensmittel der Kategorie \"lang\" noch maximal haltbar sein.
11
0.0
1

TEXTBOX
848
403
1025
459
Wie lange müssen Lebensmittel der Kategorie \"kurz\" noch maximal haltbar sein.
11
0.0
1

SLIDER
849
511
1021
544
allCat
allCat
1
112
112.0
1
1
NIL
HORIZONTAL

TEXTBOX
845
294
1016
350
Wie lange müssen Lebensmittel der Kategorie \"mittel\" noch maximal haltbar sein.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

can
false
0
Polygon -7500403 true true 150 286 118 287 79 283 49 272 32 255 49 236 78 226 117 221 150 220 150 287
Polygon -7500403 true true 150 286 182 287 221 283 251 272 268 255 251 236 222 226 183 221 150 220 150 287
Polygon -7500403 true true 150 83 118 84 79 80 49 69 32 52 49 33 78 23 117 18 150 17 150 84
Polygon -7500403 true true 150 83 182 84 221 80 251 69 268 52 251 33 222 23 183 18 150 17 150 84
Polygon -7500403 true true 35 78 42 94 50 105 46 117 41 133 50 149 41 166 36 182 45 209 36 228 32 254 152 258 151 54 32 53
Polygon -7500403 true true 265 78 258 94 250 105 254 117 259 133 250 149 259 166 264 182 255 209 264 228 268 254 148 258 149 54 268 53

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cheese
false
0
Circle -16777216 true false 54 69 42
Circle -16777216 true false 131 146 67
Polygon -7500403 true true 30 29 93 29 103 39 127 44 149 29 202 31 201 55 208 74 224 91 244 99 269 97 269 209 254 224 269 239 269 269 179 269 163 253 143 244 122 247 104 254 89 269 29 269 31 257 53 251 65 226 59 205 49 195 30 190
Circle -13345367 true false 90 105 30
Circle -13345367 true false 174 159 42

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flatbox
false
0
Polygon -7500403 true true 150 270 270 180 270 120 150 210 30 120 30 180 150 270
Polygon -7500403 true true 30 105 150 30 270 105 150 195 30 105

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

snowflake
false
0
Rectangle -7500403 true true 150 270 165 285
Rectangle -7500403 true true 165 285 180 300
Rectangle -7500403 true true 135 180 150 270
Rectangle -7500403 true true 180 195 195 210
Rectangle -7500403 true true 195 210 210 240
Rectangle -7500403 true true 210 210 225 225
Rectangle -7500403 true true 165 180 180 195
Rectangle -7500403 true true 150 165 165 180
Rectangle -7500403 true true 150 135 165 150
Rectangle -7500403 true true 165 150 255 165
Rectangle -7500403 true true 180 135 195 180
Rectangle -7500403 true true 210 135 225 180
Rectangle -7500403 true true 255 135 270 150
Rectangle -7500403 true true 270 120 285 135
Rectangle -7500403 true true 255 165 270 180
Rectangle -7500403 true true 270 180 285 195
Rectangle -7500403 true true 165 120 180 135
Rectangle -7500403 true true 180 105 195 120
Rectangle -7500403 true true 195 75 210 105
Rectangle -7500403 true true 210 90 225 105
Rectangle -7500403 true true 135 45 150 135
Rectangle -7500403 true true 150 30 165 45
Rectangle -7500403 true true 165 15 180 30
Rectangle -7500403 true true 120 195 165 210
Rectangle -7500403 true true 120 225 165 240
Rectangle -7500403 true true 120 270 135 285
Rectangle -7500403 true true 105 285 120 300
Rectangle -7500403 true true 120 105 165 120
Rectangle -7500403 true true 120 75 165 90
Rectangle -7500403 true true 120 30 135 45
Rectangle -7500403 true true 105 15 120 30
Rectangle -7500403 true true 30 150 120 165
Rectangle -7500403 true true 15 165 30 180
Rectangle -7500403 true true 0 180 15 195
Rectangle -7500403 true true 15 135 30 150
Rectangle -7500403 true true 0 120 15 135
Rectangle -7500403 true true 120 165 135 180
Rectangle -7500403 true true 120 135 135 150
Rectangle -7500403 true true 90 135 105 180
Rectangle -7500403 true true 60 135 75 180
Rectangle -7500403 true true 105 180 120 195
Rectangle -7500403 true true 90 195 105 210
Rectangle -7500403 true true 75 210 90 240
Rectangle -7500403 true true 60 210 75 225
Rectangle -7500403 true true 105 120 120 135
Rectangle -7500403 true true 90 105 105 120
Rectangle -7500403 true true 75 75 90 105
Rectangle -7500403 true true 60 90 75 105

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
