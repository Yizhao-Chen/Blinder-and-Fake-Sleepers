# Blinder-and-Fake-Sleepers

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

There is lots of details (like feedbacks) can be added in the model, but at the current stage I feel the model functioning is ok. Additional analysis will probably be another story. 






