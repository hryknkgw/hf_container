# hf_container

### ref
- https://qiita.com/Ag_smith/items/a24ca180cc971e926d89
- https://github.com/PaddlePaddle/PaddleHelix/blob/dev/apps/protein_folding/helixfold3/README.md
- https://sw-tools.rcsb.org/apps/MAXIT/README-source
- https://docs.nvidia.com/deeplearning/frameworks/paddle-paddle-release-notes/rel-24-01.html#rel-24-01
  - Last version based on CUDA 12.x and cuDNN 8.x.

### warning
- Fixed: ~~H100 is not supported paddlepaddle 2.5.x and 2.6.0 cause segmentation fault when run the helixfold~~
  - Notes: H100 is supported paddlepaddle above 2.5.0.
- Fixed: ~~to solve the issue 3.0.0.b is used for building container (cudnn > 9.0 is required to install it)~~
