<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>
<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

# Firebrand showering model configuration
## version: 0.1.8

|Feature|Description|
|:---|:---|
|Firebrand showering distance distribution |Truncated Sardoy's model|
|$\Phi$ noise                              |Added|
|Emitting location:                         |Fire Loc $-0.9<\phi<0$|
|Emitting dynamics:                          |Resident time|
|Low GR Correction:                          |True|
|Relative emitting location:                 |Cell center|
|Ember flying time correction:               |True|
|Ember generating rate definition:           |Per cell per second|
|Numerical diffusion correction:             |True|
|Simulation dimension:                       |1-D|
|Delete excessive embers:                    |True|
|End when phi is small:                      |True|
