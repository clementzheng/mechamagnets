# Mechamagnets Taxonomy

This taxonomy maps the basic physical input models afforded by Mechamagnets. It was developed by crossing 5 spatial constraints optimized for FDM printing, with 6 haptic profiles via static magnets.
<br><br><br>

## Spatial Constraints

Mass-produced physical inputs typically employ injection molding and automated assembly lines. Their designs rely on a high degree of manufacturing tolerance that is unattainable with FDM. As such, rather than mimic the construction of commercial components, we developed Mechamagnets by deconstructing existing physical inputs into simpler models.

| linear | angular | polar | planar | radial |
| --- | --- | --- | --- | --- |
|![linear spatial constraint](linear/spatialconstraint_linear.png)|![angular spatial constraint](angular/spatialconstraint_angular.png)|![polar spatial constraint](polar/spatialconstraint_polar.png)|![planar spatial constraint](planar/spatialconstraint_planar.png)|![radial spatial constraint](radial/spatialconstraint_radial.png)|

<br><br><br>

## Haptic Mechanisms

Commercial inputs rely on an assembly of different components to deliver haptic feedback and mechanical behavior. For instance, a mechanical keyboard button uses contact leaves to generate a “click” when it is pressed (haptic feedback), and a spring to push it back to its original position (mechanical behavior). In Mechamagnets, we investigated using only static magnets and 3D printing (Figure 2 bottom) to specify different unpowered haptic feedback as well as mechanical behaviors of inputs.

![haptic mechanisms](hapticmechanisms.png)

<br><br><br>

## Taxonomy

| | attracting<br>center | repelling<br>center | attracting<br>steps | repelling<br>steps | attracting<br>end | repelling<br>end |
| --- | --- | --- | --- | --- | --- | --- |
| **linear** | ![linear x attacting center](linear/linear_attracting-center/linear_attracting-center.png)<br>[STL Files](linear/linear_attracting-center)<br>[Fusion 360](https://a360.co/2qmrZ0z) | ![linear x repelling center](linear/linear_repelling-center/linear_repelling-center.png)<br>[STL Files](linear/linear_repelling-center)<br>[Fusion 360](https://a360.co/2CTjDoC) | ![linear x attacting steps](linear/linear_attracting-steps/linear_attracting-steps.png)<br>[STL Files](linear/linear_attracting-steps)<br>[Fusion 360](https://a360.co/2QciaNM) | ![linear x repelling steps](linear/linear_repelling-steps/linear_repelling-steps.png)<br>[STL Files](linear/linear_repelling-steps)<br>[Fusion 360](https://a360.co/2CTtLh6) | ![linear x attacting end](linear/linear_attracting-end/linear_attracting-end.png)<br>[STL Files](linear/linear_attracting-end)<br>[Fusion 360](https://a360.co/2P4Ywqs) | ![linear x repelling end](linear/linear_repelling-end/linear_repelling-end.png)<br>[STL Files](linear/linear_repelling-end)<br>[Fusion 360](https://a360.co/2qoJdKs) |
| **angular** | ![angular x attacting center](angular/angular_attracting-center/angular_attracting-center.png)<br>[STL Files](angular/angular_attracting-center)<br>[Fusion 360](https://a360.co/2qpvH9G) | ![angular x repelling center](angular/angular_repelling-center/angular_repelling-center.png)<br>[STL Files](angular/angular_repelling-center)<br>[Fusion 360](https://a360.co/2CUSt0w) | ![angular x attacting steps](angular/angular_attracting-steps/angular_attracting-steps.png)<br>[STL Files](angular/angular_attracting-steps)<br>[Fusion 360](https://a360.co/2P2tEaq) | ![angular x repelling steps](angular/angular_repelling-steps/angular_repelling-steps.png)<br>[STL Files](angular/angular_repelling-steps)<br>[Fusion 360](https://a360.co/2qoea1K) | ![angular x attacting end](angular/angular_attracting-end/angular_attracting-end.png)<br>[STL Files](angular/angular_attracting-end)<br>[Fusion 360](https://a360.co/2CVcvb6) | ![angular x repelling end](angular/angular_repelling-end/angular_repelling-end.png)<br>[STL Files](angular/angular_repelling-end)<br>[Fusion 360](https://a360.co/2CYElDk) |
| **polar** | ![polar x attacting center](polar/polar_attracting-center/polar_attracting-center.png)<br>[STL Files](polar/polar_attracting-center)<br>[Fusion 360](https://a360.co/2CVeT1y) | ![polar x repelling center](polar/polar_repelling-center/polar_repelling-center.png)<br>[STL Files](polar/polar_repelling-center)<br>[Fusion 360](https://a360.co/2qvsPIx) | ![polar x attacting steps](polar/polar_attracting-steps/polar_attracting-steps.png)<br>[STL Files](polar/polar_attracting-steps)<br>[Fusion 360](https://a360.co/2CRoc2N) | ![polar x repelling steps](polar/polar_repelling-steps/polar_repelling-steps.png)<br>[STL Files](polar/polar_repelling-steps)<br>[Fusion 360](https://a360.co/2qqlvxr) | ![polar x attacting end](polar/polar_attracting-end/polar_attracting-end.png)<br>[STL Files](polar/polar_attracting-end)<br>[Fusion 360](https://a360.co/2CUTGF6) | ![polar x repelling end](polar/polar_repelling-end/polar_repelling-end.png)<br>[STL Files](polar/polar_repelling-end)<br>[Fusion 360](https://a360.co/2qo1E1X) |
| **planar** | ![planar x attacting center](planar/planar_attracting-center/planar_attracting-center.png)<br>[STL Files](planar/planar_attracting-center)<br>[Fusion 360](https://a360.co/2Qax5rS) | ![planar x repelling center](planar/planar_repelling-center/planar_repelling-center.png)<br>[STL Files](planar/planar_repelling-center)<br>[Fusion 360](https://a360.co/2CVDOlG) | ![planar x attacting steps](planar/planar_attracting-steps/planar_attracting-steps.png)<br>[STL Files](planar/planar_attracting-steps)<br>[Fusion 360](https://a360.co/2CST0A9) | ![planar x repelling steps](planar/planar_repelling-steps/planar_repelling-steps.png)<br>[STL Files](planar/planar_repelling-steps)<br>[Fusion 360](https://a360.co/2qlUNGm) | ![planar x attacting end](planar/planar_attracting-end/planar_attracting-end.png)<br>[STL Files](planar/planar_attracting-end)<br>[Fusion 360](https://a360.co/2CTwSFO) | |
| **radial** |  ![radial x attacting center](radial/radial_attracting-center/radial_attracting-center.png)<br>[STL Files](radial/radial_attracting-center)<br>[Fusion 360](https://a360.co/2CWUr0f) | |  ![radial x attacting steps](radial/radial_attracting-steps/radial_attracting-steps.png)<br>[STL Files](radial/radial_attracting-steps)<br>[Fusion 360](https://a360.co/2CT3n6S) | | | |

![Legend](taxonomy_legend.png)