globals [ explored_sub-region_number ]  ;;set the global variable to receive results for the sub-region number being explored
patches-own [on-path? sub-region turtle-reached? resource-rate num-patches num-turtles] ;;set the patch own properties
turtles-own [current-region residence-time initial-heading recognition-ability has-settled? ] ;;set the turtle own properties

;;create three groups of turtles
breed [Blds Bld]
breed [FSs FS]
breed [Insts Inst]

;; Setup procedure
to setup
  clear-all      ;;clear all sets from previous run
  resize-world -50 50 -50 50  ;; Enlarge the world

  ;; Initialize all patches
  ask patches [
    set on-path? false ;;set all patches with on-path property false
    set pcolor black   ;;set the color
  ]
  ;; Set up the cycling path as a spiral loop
  let radius 0
  let angle 0
  let max-radius 40
  let angle-increment 5.13  ;; Adjust this value to change the spiral tightness, the value is set to let the color of the circles from a specific angle to the center point is approximately the same.

  ;; Define sub-regions based on radius intervals
  let sub-region-interval 1  ;; Each sub-region covers a 1-unit radius interval
  let current-sub-region 1  ;; Start with the first sub-region

  ;; Create the spiral path
  while [radius < max-radius] [
    let px round (radius * cos angle)
    let py round (radius * sin angle)
    if (px >= min-pxcor and px <= max-pxcor and py >= min-pycor and py <= max-pycor) [
      ;; Mark the central path patch
      let width max list 1 (radius / 10)  ;; Adjust the width dynamically
      ask patches with [distancexy px py <= width] [
        set on-path? true
        set sub-region current-sub-region ;;Assign the sub-region
        set-sub-region-color sub-region  ;; Set the color based on sub-region
        set turtle-reached? false  ;; Initialize turtle-reached as false
        set resource-rate 0  ;; Initialize resource rate to 0
        set num-patches 0  ;; Initialize num-patches to 0
        set num-turtles 0  ;; Initialize num-turtles to 0
      ]
    ]

    set angle (angle + angle-increment)
    set radius (radius + 0.2)  ;; Increment the radius gradually

    ;; Check if we need to move to the next sub-region
    if radius >= (current-sub-region * sub-region-interval) [
      set current-sub-region current-sub-region + 1
    ]
  ];;end of while

  ;; Get a list of unique sub-regions
  ;;let unique-subregions remove-duplicates [sub-region] of patches
  ;; Initialize an index for the while loop
  ;;let i 0
  ;; Calculate the number of patches for each sub-region using a while loop
  ;;while [i < length unique-subregions] [
  ;;  let region item i unique-subregions
  ;;  let count-in-region count patches with [sub-region = region]
  ;;  table:put subregion-patch-counts region count-in-region
  ;; set i i + 1
  ;;]

    ;; Extract keys and sort them
  ;;let sorted-subregions sort table:keys subregion-patch-counts

    ;; Print the counts for each sub-region in sorted order
  ;;foreach sorted-subregions [ region ->
  ;;  show (word region ": " table:get subregion-patch-counts region)
  ;;]

  ;; Create 10 Bld turtles with random initial directions
  create-Blds 10 [
    set color white
    set shape "triangle"
    let target-patch one-of patches with [sub-region = 40]  ;;let the initial position of the turtle in sub-region #40
    if target-patch != nobody [
      move-to target-patch
    ]
    set current-region [sub-region] of patch-here ;;set the current-region property to the sub-region code where the turtle locates
    set heading random 360
    set initial-heading heading
    set residence-time 0 ;;initialize the residence time to 0
  ]

  reset-ticks
end;; End of setup procedure

;;Go procedure
to go
  ;; Create a number of Blds every 10 ticks
  if (ticks mod 10 = 0) [
    create-Blds Bld_birth_rate  [
      set color white
      set shape "triangle"
      let target-patch one-of patches with [sub-region = 40] ;;let the initial position of the turtle in sub-region #40
      if target-patch != nobody [
        move-to target-patch
      ]
      set current-region [sub-region] of patch-here
      set heading random 360 ;;random moving direction
      set initial-heading heading
      set residence-time 0
    ]
  ]

  ;; Create a number of FSs every 10 ticks
  if (ticks mod 10 = 0) [
    create-FSs FS_birth_rate [
      set color white
      set shape "circle"
      set recognition-ability random max_recognition_ability + 1  ;; Assign a random recognition-ability between 1 and max_recognition_ability
      set has-settled? false;; Initialize has-settled? to false
      set residence-time 0


      ;;set angle1 0
      ;;let target-patch one-of patches with [sub-region = 40]
      ;;if target-patch != nobody [
      ;;  move-to target-patch

      ;;set initial-x xcor
      ;;set initial-y ycor
      ;;code to set initial position at a single point
      ;;setxy inital_pxcor inital_pycor
      ;; Ensure the initial position is on the path
      ;;while [not on-path?] [
      ;;  setxy inital_pxcor inital_pycor
      ;;]
      ;;set current-region [sub-region] of patch-here
      ;;set heading random 360
      ;;set initial-heading heading
      ]
    ]


  ;; Create 1 instinctor every 100 ticks
  if (ticks mod 100 = 0) [
    create-Insts 1 [
      set color black
      set shape "star"
      let target-patch one-of patches with [sub-region = 40]
      if target-patch != nobody [
        move-to target-patch
      ]
      set current-region [sub-region] of patch-here
      set heading random 360
      set residence-time 0
    ]
  ]


  ;; Move Bld turtles within the path
  ask Blds [
    ;; Move in the initial direction
    set heading initial-heading
    let target-patch patch-ahead 1
    ;; Check if the target patch is within bounds and on the path
    if (target-patch != nobody and [on-path?] of target-patch and [sub-region] of target-patch <= current-region) [
      forward 1
       ;; Update the current sub-region if moved to a lower/inner one
      if [sub-region] of target-patch < current-region [
        set current-region [sub-region] of target-patch
      ]
    ]
     ;; If hitting the edge of the path, turn in the opposite direction
    if (target-patch = nobody or not [on-path?] of target-patch or [sub-region] of target-patch > current-region) [
      reflect-heading
    ]

    let current-patch patch-here
    let current-sub-region1 [sub-region] of current-patch ;; Store the sub-region of the current patch

    ;; If a turtle reaches this patch, mark the entire sub-region as reached
    ask patches with [sub-region = current-sub-region1] [
      set turtle-reached? true
    ]

    ;; Increment residence-time and check if it reaches the threshold
    set residence-time residence-time + 1
    if residence-time >= residence_time_threshold [
      die
    ]


  ]

  ;; Locate FSs within the path
  ask FSs with [has-settled? = false] [ ;;initialize has-settled property to be false
    ;;Identify recognized sub-regions based on recognition-ability
    let recognized-regions sublist (range 1 41) (40 - recognition-ability) 40
    ;;Find the sub-region with the maximum resource-rate
    let max-resource-region max-one-of patches with [
      member? sub-region recognized-regions and turtle-reached? = true
    ] [resource-rate]
    if max-resource-region != nobody [
      ;; Place FS in a random patch in the sub-region with the maximum resource-rate
      let target-patch one-of patches with [sub-region = [sub-region] of max-resource-region]
      if target-patch != nobody [
        move-to target-patch  ;; Move the FS to the target patch
        set has-settled? true  ;; Mark the FS as settled, preventing further movement
      ]
    ]

    let current-patch patch-here
    let current-sub-region1 [sub-region] of current-patch ;; Store the sub-region of the current patch

    ;; If a turtle reaches this patch, mark the entire sub-region as reached
    ask patches with [sub-region = current-sub-region1] [
      set turtle-reached? true
    ]

    ;; Increment residence-time and check if it reaches the threshold
    set residence-time residence-time + 1
    if residence-time >= residence_time_threshold [
      die
    ]
  ]

  ;; Move Insts turtles randomly within the path
  ask Insts [
    right random 360
    let target-patch patch-ahead 1
    ;; Check if the target patch is within bounds and on the path
    if (target-patch != nobody and [on-path?] of target-patch and [sub-region] of target-patch <= current-region) [
      forward 1
    ;; Update the current sub-region if moved to a lower one
      if [sub-region] of target-patch < current-region [
        set current-region [sub-region] of target-patch
      ]
    ]

    let current-patch patch-here
    let current-sub-region1 [sub-region] of current-patch ;; Store the sub-region of the current patch

    ;; If a turtle reaches this patch, mark the entire sub-region as reached
    ask patches with [sub-region = current-sub-region1] [
      set turtle-reached? true
    ]

    ;; Increment residence-time and check if it reaches the threshold
    set residence-time residence-time + 1
    if residence-time >= 1000000 [
      die
    ]
  ]


  ;; Create lists to store the data for plotting
  let patch-counts []
  let turtle-counts []
  let resource-rates []
  let valid-sub-regions []  ;; List to track sub-regions that are actually being plotted


  ;; Update num-patches, num-turtles, and resource-rate for each sub-region
  let all-sub-regions remove-duplicates [sub-region] of patches
  foreach all-sub-regions [
    current-sub-region ->
    if current-sub-region != 0 [  ;; Ensure the sub-region is valid
      let patch-count count patches with [sub-region = current-sub-region]
      let turtle-count count turtles with [sub-region = current-sub-region]

      let rate 0  ;; Initialize rate to 0
      if turtle-count > 0 [
        set rate alpha * patch-count / turtle-count  ;; Calculate rate if turtles are present
      ]

      ;; Update num-patches, num-turtles, and resource-rate for all patches in the sub-region
      ask patches with [sub-region = current-sub-region] [
        set num-patches patch-count
        set num-turtles turtle-count
        set resource-rate rate
      ]

      ;; Collect the data for this sub-region
      set patch-counts lput patch-count patch-counts
      set turtle-counts lput turtle-count turtle-counts
      set resource-rates lput rate resource-rates
      set valid-sub-regions lput current-sub-region valid-sub-regions
    ]
  ]

;; Identify unique sub-regions with turtle-reached? = true
  let explored-sub-regions remove-duplicates [sub-region] of patches with [turtle-reached? = true]

  ;; Count the number of these sub-regions
  set explored_sub-region_number length explored-sub-regions

  ;; Plot the values for each sub-region
  set-current-plot "Patch_num_subregion"

  ;; Iterate over each valid sub-region to plot the collected data
  let sub-region-index 0
  foreach valid-sub-regions [
    current-sub-region ->
    ;; Plot for num-patches
    set-current-plot-pen (word "sub-" current-sub-region)
    plotxy ticks item sub-region-index patch-counts

    set sub-region-index sub-region-index + 1
  ]

  ;; Plot the values for each sub-region
  set-current-plot "Turtle_count_subregion"

  ;; Iterate over each valid sub-region to plot the collected data
  let sub-region-index1 0
  foreach valid-sub-regions [
    current-sub-region ->
    ;; Plot for turtle-counts
    set-current-plot-pen (word "sub-" current-sub-region)
    plotxy ticks item sub-region-index1 turtle-counts

    set sub-region-index1 sub-region-index1 + 1
  ]


    ;; Plot the values for each sub-region
  set-current-plot "Resource_rate_subregion"

  ;; Iterate over each valid sub-region to plot the collected data
  let sub-region-index2 0
  foreach valid-sub-regions [
    current-sub-region ->
    ;; Plot for resource-rates
    set-current-plot-pen (word "sub-" current-sub-region)
    plotxy ticks item sub-region-index2 resource-rates

    set sub-region-index2 sub-region-index2 + 1
  ]

  tick
end
;;end of Go procedure

;;funtion to set sub-region color
to set-sub-region-color [sub-region1]
  ;; Use a color scale based on the sub-region number
  let color-map [red orange yellow green blue violet magenta]
  let color-index (sub-region1 - 1) mod length color-map
  set pcolor item color-index color-map
end

;;function to reflect heading of Blds
to reflect-heading
  ;; Calculate the normal to the edge
  let normal (towardsxy (pxcor + 1) pycor) - 90
  set heading (2 * normal - heading) mod 360
  set initial-heading heading
end

;;====================================================================================================================================================================================
;;Temporal codes for tests
;;====================================================================================================================================================================================

;; Helper function to check if a patch exists
;;to-report patch-exists? [x y]
;;  report (x >= min-pxcor and x <= max-pxcor and y >= min-pycor and y <= max-pycor)
;;end


;; Calculate and mark the middle patch for each angle
;;to calculate-middle-patches
;;  ask patches [
;;    set middle-patch? false  ;; Reset all patches
;;  ]
;;  let angles (list 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 205 210 215 220 225 230 235 240 245 250 255 260 265 270 275 280 285 290 295 300 305 310 315 320 325 330 335 340 345 350 355)
;;  foreach angles [
;;    angle ->
;;    let patches-at-angle patches with [round towardsxy 0 0 = angle and on-path?]
;;    if any? patches-at-angle [
;;      let sorted-patches sort-by [distancexy 0 0] patches-at-angle
;;      let middle-index (length sorted-patches / 2)
;;      let middle-patch item middle-index sorted-patches
;;      ask middle-patch [
;;        set middle-patch? true
;;        set pcolor blue  ;; Mark the middle patch for visualization
;;      ]
;;    ]
;;]
;;end

;;to go
;;  ask Blds [
;;    let moved? false
;;    let attempts 0
;;    while [not moved? and attempts < 8] [
;;     right random 360 / 8  ;; Try different directions in 45-degree increments
;;      let target-patch patch-ahead 1
      ;; Check if the target patch is valid, on the path, and within the allowed sub-region
;;      if (target-patch != nobody and [on-path?] of target-patch and [sub-region] of target-patch <= current-region) [
;;        move-to target-patch
;;        set moved? true
        ;; Update the current sub-region if moved to a lower one
;;        if [sub-region] of target-patch < current-region [
;;          set current-region [sub-region] of target-patch
;;        ]
;;      ]
;;      set attempts attempts + 1
;;    ]
;;  ]

;;  tick
;;end
@#$#@#$#@
GRAPHICS-WINDOW
190
27
781
619
-1
-1
5.7723
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
6
36
72
69
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
6
73
72
106
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
1

SLIDER
1
156
173
189
Bld_birth_rate
Bld_birth_rate
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
194
173
227
FS_birth_rate
FS_birth_rate
0
10
0.0
1
1
NIL
HORIZONTAL

PLOT
783
10
1000
652
Patch_num_subregion
Time
Patch-count
0.0
100.0
0.0
200.0
true
true
"" ""
PENS
"sub-1" 1.0 0 -8053223 true "" ""
"sub-2" 1.0 0 -5298144 true "" ""
"sub-3" 1.0 0 -2674135 true "" ""
"sub-4" 1.0 0 -2139308 true "" ""
"sub-5" 1.0 0 -1604481 true "" ""
"sub-6" 1.0 0 -6995700 true "" ""
"sub-7" 1.0 0 -3844592 true "" ""
"sub-8" 1.0 0 -955883 true "" ""
"sub-9" 1.0 0 -817084 true "" ""
"sub-10" 1.0 0 -612749 true "" ""
"sub-11" 1.0 0 -7171555 true "" ""
"sub-12" 1.0 0 -4079321 true "" ""
"sub-13" 1.0 0 -1184463 true "" ""
"sub-14" 1.0 0 -987046 true "" ""
"sub-15" 1.0 0 -723837 true "" ""
"sub-16" 1.0 0 -15040220 true "" ""
"sub-17" 1.0 0 -14439633 true "" ""
"sub-18" 1.0 0 -13840069 true "" ""
"sub-19" 1.0 0 -11085214 true "" ""
"sub-20" 1.0 0 -8330359 true "" ""
"sub-21" 1.0 0 -13403783 true "" ""
"sub-22" 1.0 0 -12345184 true "" ""
"sub-23" 1.0 0 -11221820 true "" ""
"sub-24" 1.0 0 -8990512 true "" ""
"sub-25" 1.0 0 -6759204 true "" ""
"sub-26" 1.0 0 -14730904 true "" ""
"sub-27" 1.0 0 -14070903 true "" ""
"sub-28" 1.0 0 -13345367 true "" ""
"sub-29" 1.0 0 -10649926 true "" ""
"sub-30" 1.0 0 -8020277 true "" ""
"sub-31" 1.0 0 -11783835 true "" ""
"sub-32" 1.0 0 -10141563 true "" ""
"sub-33" 1.0 0 -8630108 true "" ""
"sub-34" 1.0 0 -6917194 true "" ""
"sub-35" 1.0 0 -5204280 true "" ""
"sub-36" 1.0 0 -10022847 true "" ""
"sub-37" 1.0 0 -7858858 true "" ""
"sub-38" 1.0 0 -5825686 true "" ""
"sub-39" 1.0 0 -4699768 true "" ""
"sub-40" 1.0 0 -3508570 true "" ""

PLOT
1002
10
1227
652
Turtle_count_subregion
Time
Turtle-count
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sub-1" 1.0 0 -8053223 true "" ""
"sub-2" 1.0 0 -5298144 true "" ""
"sub-3" 1.0 0 -2674135 true "" ""
"sub-4" 1.0 0 -2139308 true "" ""
"sub-5" 1.0 0 -1604481 true "" ""
"sub-6" 1.0 0 -6995700 true "" ""
"sub-7" 1.0 0 -3844592 true "" ""
"sub-8" 1.0 0 -955883 true "" ""
"sub-9" 1.0 0 -817084 true "" ""
"sub-10" 1.0 0 -612749 true "" ""
"sub-11" 1.0 0 -7171555 true "" ""
"sub-12" 1.0 0 -4079321 true "" ""
"sub-13" 1.0 0 -1184463 true "" ""
"sub-14" 1.0 0 -987046 true "" ""
"sub-15" 1.0 0 -723837 true "" ""
"sub-16" 1.0 0 -15040220 true "" ""
"sub-17" 1.0 0 -14439633 true "" ""
"sub-18" 1.0 0 -13840069 true "" ""
"sub-19" 1.0 0 -11085214 true "" ""
"sub-20" 1.0 0 -8330359 true "" ""
"sub-21" 1.0 0 -13403783 true "" ""
"sub-22" 1.0 0 -12345184 true "" ""
"sub-23" 1.0 0 -11221820 true "" ""
"sub-24" 1.0 0 -8990512 true "" ""
"sub-25" 1.0 0 -6759204 true "" ""
"sub-26" 1.0 0 -14730904 true "" ""
"sub-27" 1.0 0 -14070903 true "" ""
"sub-28" 1.0 0 -13345367 true "" ""
"sub-29" 1.0 0 -10649926 true "" ""
"sub-30" 1.0 0 -8020277 true "" ""
"sub-31" 1.0 0 -11783835 true "" ""
"sub-32" 1.0 0 -10141563 true "" ""
"sub-33" 1.0 0 -8630108 true "" ""
"sub-34" 1.0 0 -6917194 true "" ""
"sub-35" 1.0 0 -5204280 true "" ""
"sub-36" 1.0 0 -10022847 true "" ""
"sub-37" 1.0 0 -7858858 true "" ""
"sub-38" 1.0 0 -5825686 true "" ""
"sub-39" 1.0 0 -4699768 true "" ""
"sub-40" 1.0 0 -3508570 true "" ""

PLOT
1228
10
1467
653
Resource_rate_subregion
Time
Resource-rate
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sub-1" 1.0 0 -8053223 true "" ""
"sub-2" 1.0 0 -5298144 true "" ""
"sub-3" 1.0 0 -2674135 true "" ""
"sub-4" 1.0 0 -2139308 true "" ""
"sub-5" 1.0 0 -1604481 true "" ""
"sub-6" 1.0 0 -6995700 true "" ""
"sub-7" 1.0 0 -3844592 true "" ""
"sub-8" 1.0 0 -955883 true "" ""
"sub-9" 1.0 0 -817084 true "" ""
"sub-10" 1.0 0 -612749 true "" ""
"sub-11" 1.0 0 -7171555 true "" ""
"sub-12" 1.0 0 -4079321 true "" ""
"sub-13" 1.0 0 -1184463 true "" ""
"sub-14" 1.0 0 -987046 true "" ""
"sub-15" 1.0 0 -723837 true "" ""
"sub-16" 1.0 0 -15040220 true "" ""
"sub-17" 1.0 0 -14439633 true "" ""
"sub-18" 1.0 0 -13840069 true "" ""
"sub-19" 1.0 0 -11085214 true "" ""
"sub-20" 1.0 0 -8330359 true "" ""
"sub-21" 1.0 0 -13403783 true "" ""
"sub-22" 1.0 0 -12345184 true "" ""
"sub-23" 1.0 0 -11221820 true "" ""
"sub-24" 1.0 0 -8990512 true "" ""
"sub-25" 1.0 0 -6759204 true "" ""
"sub-26" 1.0 0 -14730904 true "" ""
"sub-27" 1.0 0 -14070903 true "" ""
"sub-28" 1.0 0 -13345367 true "" ""
"sub-29" 1.0 0 -10649926 true "" ""
"sub-30" 1.0 0 -8020277 true "" ""
"sub-31" 1.0 0 -11783835 true "" ""
"sub-32" 1.0 0 -10141563 true "" ""
"sub-33" 1.0 0 -8630108 true "" ""
"sub-34" 1.0 0 -6917194 true "" ""
"sub-35" 1.0 0 -5204280 true "" ""
"sub-36" 1.0 0 -10022847 true "" ""
"sub-37" 1.0 0 -7858858 true "" ""
"sub-38" 1.0 0 -5825686 true "" ""
"sub-39" 1.0 0 -4699768 true "" ""
"sub-40" 1.0 0 -3508570 true "" ""

MONITOR
1
318
188
363
NIL
explored_sub-region_number
0
1
11

SLIDER
1
273
188
306
residence_time_threshold
residence_time_threshold
100
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
0
233
174
266
max_recognition_ability
max_recognition_ability
3
40
40.0
1
1
NIL
HORIZONTAL

SLIDER
1
118
173
151
alpha
alpha
0.1
10
1.0
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## Model Scope

The model called "Blinders and the fake sleepers" here describes my understanding of how innovative progress is approached in a particular (scientific) field, based on my personal observation and experience after working with researchers from several disciplines. Specifically, the model describes the  progress of a (scientific) field as a spire-like pathway, with the width of the path gradually becoming narrower. The design of the world suggests that the resource (like fundings in real world) are abundant and easily accessible in the outer circles. While as one moves closer to the center, resources become scarcer, and the difficulty of advancing increases. Yet, once a person reaches the inner circles of the spire-like pathway, they gain access to all the resources available there.


Three types of agents/turtles, i.e., Blinders (Blds), Fake Sleepers(FSs) and Instinctors(Insts),each with distinct behaviors, exploring the world to achieve their own goals. The model simulates how these individual behaviors collectively contribute to the progress of a field, demonstrating how actions at the individual level shape the overall pattern of innovative progress across the entire domain.


## Agent Selection

Three types of agents are set in this model, namely Blinders (Blds), Fake Sleepers(FSs) and Instinctors(Insts).

The name ”Blinders” is originally from an ancient story recorded in Buddhist
texts.
”The parable of the blind men and an elephant is a story of a group of blind men who have never come across an elephant before and who learn and imagine what the elephant is like by touching it. Each blind man feels a different part of the animal’s body, but only one part, such as the side or the tusk. They then describe the animal based on their limited experience and their descriptions of the elephant are different from each other. In some versions, they come to suspect that the other person is dishonest and they come to blows. The moral of the parable is that humans have a tendency to claim absolute truth based on their limited, subjective experience as they ignore other people’s limited, subjective experiences which may be equally true. The parable originated in the ancient Indian subcontinent, from where it has been widely diffused.”
–Wikipedia

So it describes a group of people who will always build theories and act following their observation and understanding about the world. From the name, it defines two basic principles of their actions: 1. In most cases, their knowledge is limited to the scope they possess; and 2. they seek to explore the world as confirmed by their understanding, and they judge facts rather than considering other factors such as the environment and the potential benefits of the output. Unlike the original story, the Blds in my model do not communicate with each other and keep arguing about the correctness of their predictions. Instead, they explore the world independently based on their own understanding.

The name "Fake Sleepers" is from an ancient Navajo proverb "one can never wake up a person who is pretending to be asleep".  This term describes a segment of the community that makes decisions to maximize their own benefit, rather than the facts they have observed. They do not explore new parts of the world but instead learn from the ideas of the Blds and follow one of them they believe will benefit them the most.

The third type of agent, "Instinctors", describes a group of people who follows their own instinct to explore the world with a free mind. Following the concept, they can explore the world freely. Currently it is a temporal set and their behaviors need a further consideration.

## Agent Properties
The follwing are the agent properties: current-region residence-time initial-heading recognition-ability has-settled?

current-region: a variable to store the current sub-region where one agent/turtle is located.
residence-time: a variable to store the existing time/ticks of one agent/turtle in the world. 
initial-heading: a variable to define the moving direction of one agent/turtle.
recognition ability: a random integer (1-40) to define the recognition extension (number of sub-region) of one FS.    

## Agent Actions

Blds: The agents can move freely within the spire-like path. Once a moving direction is randomly prescribed, the Blds will maintain such movement, i.e., the angle of movement. Once an agent touches the edge of the path, it will bounce back based on the direction it touches the edge*. Once an agent enters in a new sub-region, it will not go back the previous sub-region. One Bld will be removed from the world once its residence time reaches the threshold.

FSs: The agents determine their location within the pathway** based on resource availability (as detailed in the "Agent Environment" section) and their recognition ability. Specifically, they seek out the sub-region with the maximum resource availability that they can perceive and position themselves randomly within that sub-region. An FS will be removed from the world once its residence time exceeds the set threshold.

Insts: The agents can move freely within the spire-like path. Once an agent enters in a new sub-region, it will not go back the previous sub-region. One Inst will be removed from the world once its residence time reaches the threshold***.


*This set of bouncing back can cause Blds to become stuck along certain edges of the pathway, as the path is not "smoothly" circular. This outcome somehow aligns with my design, as Blds, with their limited perception of the world, are prone to getting stuck somewhere.

**Alternative advanced design:  Once an FS identifies the target sub-region and then it will establish a link to a Bld/Inst, it will follow the movement of that turtle until the turtle's residence time expires. The FS will then reassess the resource availability and attempt to find another Bld to link with.

***The residence time threshold is set to a very large number (=1000000 ticks) to enable its full exploration of the pathway.   



## Environment

The enviroment will be generated after the user hit 'setup'.

The overall environment for turtles to move is a spire-like cycles, as I described in the "model scope" section. So it is a type of spatial environment. The environment restricts the turtles to moving only within the path, which becomes increasingly narrower as they approach the center point.The pathway is divided into 40 sub-regions, with lower sub-region numbers indicating closer proximity to the center (e.g., sub-region #40 represents the outermost areas, while sub-region #1 represents the innermost). Each sub-region is distinguished by different colors, with colors from a specific angle to the center remaining approximately consistent, symbolizing how a particular (scientific) question can recur in the real world, yet continues to evolve with advancements in science and technology.

According to the moving rules defined in the "Agent Actions" section, the movements of Blds will only be restricted by the path itself. Once they touch an edge of the cycle, they will turn around using the same prescribed moving angle or, just stuck there. Blds never move back to the old sub-region they have passed.

The environment influences the location of FSs based on resource availability, determined by a patch property called "resource-rate". Resource-rate is affected by two factors: the space within a specific area of the cycles that has already been explored by agents (the resource factor, represented by the patch property "num-patches") and the number of individual agents currently occupying that area (the population factor, represented by the patch property "num-turtles"). The resource availability is calculated using the following equation:
                 resource-rate = alpha * num-patches / num-turtles             (1)
where alpha is the weight of the two factors.

For each sub-region, the num-patches and the num-turtles within it can be quantified. The num-patches in each sub-region is predefined by the pathway, while the dynamics of num-turtles is calculated based on the current number of agents in a specific sub-region at each tick. The weight of these two factors, represented by alpha in equation (1), can be adjusted using a slider labeled "alpha." Once an FS identifies its target sub-region, it will be placed in a random patch within that sub-region.

Similar to Blds, the enviroment will only restrict the movement of Insts by the path itself. Instead of being prescribed by a certain moving direction, Insts can move freely in the pathway but never move back to the old sub-region they have passed. 

## Order of Events and Model Execution

To start the simulation, the environment is created by clicking ‘setup’. In the meantime, there will be 10 initial Blds created randomly located in the sub-region #40, i.e., the out-most sub-region. Users can adjust the model's inputs before running the setup.

The simulation runs are executed by clicking ‘go’.

(1) 1-10 (default = 5) Bld/s is/are created for each 10 ticks.

(2) 1-10 (default = 5) FSs is created for each 10 ticks.

(3) 1 Inst is created for each 100 ticks.

(4) For each tick, the existing Blds and Insts move following their action rules as described above. If their residence time reaches the threshold value, they are removed from the world.

(5) Once a FS being created, it will find a random patch in a specific sub-region based on its action rules as described above.

(6) The number of patches and turtles and the resource rate for each sub-region are calculated and plotted.

(7) The number of explored sub-regions are calculated and being presented in the monitor named "explored_sub-region_number".


## Inputs and Outputs
Inputs:
(1) Bld_born_rate: the number of Bld being created every 10 ticks. The range is 1-10.

(2) FS_born_rate: the number of FS being created every 10 ticks. The range is 1-10.

(3) residence_time_threshold: the maximum residence time for Blds and FSs. The range is 100-500.

(4) recognition_ability: The range of sub-regions that an FS can evaluate for resource availability. The range is 1-40.

(5) alpha: the relative weight of resource factor (number of patches in a sub-region) and population factor (number of existing turtles in a sub-region). The range is 0.1 - 10. Value < 1 means the weight of resource factor is smaller than the population factor. Value = 1 means the weight of resource factor equals to the population factor. Value > 1 means the weight of resource factor is larger than the population factor.

Outputs: 
(1) Explored sub-region number (Monitor): The sub-region that have been explored by at least one turtle.
(2) Patch number in each sub-region (Plot), which is constant over time.
(3) Turtle count in each sub-region (Plot).
(4) Resource rate in each sub-region (Plot).


## Notes to the model
The toy model here, in fact, does not target to a specific scientific question, but rather reflects my personal understanding of the functioning of (scientific) communities I observed in general. It is important to note that the phenomenon described here to me is the very basic part of science. Once a turtle reaches the center of the cycles, a world of a higher dimension will appear to it. Currently I do not know how to describe this higher-dimensional world, as it is out of my scope.

The current set of agents provides a relatively extreme version of the model. In the real world, people are usually a mix of "Blinder" and "Fake Sleeper", with a tendency towards one or the other. For the simplicity and clarity, I decide to build the first model with only these two extreme types to illustrate my point.

The model runs slow on my laptop (CPU:12th Gen Intel(R) Core(TM) i5-1240P 1.70 GHz, RAM: 40 GB, OS: win11) if the turtles appears too fast in the world. So I restrict the born rate of Bld and FS to a relatively low values.

The interface appears large on a 14-inch monitor, like my laptop. This is because I enable legend for the plots so it is easier to check the results for each sub-region. It is perfect for a 27-inch monitor:)  

At the moment, I have not fully analysis the output. But some potentially interesting patterns come to me: 1. The movement of Blds initially drives innovative progress, but eventually, Insts take over; 2.When a new sub-region is explored, its resource availability spikes but can decrease sharply as some FSs become aware of it; 3. The turtle number in the middle section of the path will eventually become the highest, if the model runs for long. 

There is lots of details (like feedbacks) can be added in the model, but at the current stage I feel the model functioning is ok as an output for the course. Additional analysis will probably be another story. 







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

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

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
NetLogo 6.3.0
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
