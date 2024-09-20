# hf_container

### ref
- https://qiita.com/Ag_smith/items/a24ca180cc971e926d89

### warning
- H100 is not supported paddlepaddle 2.5.x and 2.6.0 cause segmentation fault when run the helixfold
- to solve the issue 3.0.0.b is used for build container (cudnn > 9.0 is required to install it)
