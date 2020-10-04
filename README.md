[![latex](https://github.com/yegor256/size-vs-immutability/workflows/latex/badge.svg)](https://github.com/yegor256/size-vs-immutability/actions?query=latex)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/size-vs-immutability/blob/master/LICENSE.txt)

Question: Is there a correlation between Java class size and its
immutability? It is suggested that immutable classes are smaller.
This research proves this hypothesis. The article was presented
at [KES 2020](http://kes2020.kesinternational.org/) conference
and published by [Elsevier](https://www.sciencedirect.com/science/article/pii/S1877050920321281#!).
If you want to cite this paper, use this:

```
@article{bugayenko2020immutability,
  author={Yegor Bugayenko and Sergey Zykov},
  title={The Impact of Object Immutability on the Java Class Size},
  journal={Procedia Computer Science},
  volume={176},
  pages={1868--1872},
  year={2020}
}
```

You need to have installed:

  * LaTeX
  * Make
  * Git
  * Python 3.7+
  * Ruby 2.6+

Just run `make` and in a few <del>seconds</del> hours, you will get
`article.pdf` file ready inside `/paper`.

Don't want to compile? Just read the [PDF](https://github.com/yegor256/size-vs-immutability/releases/latest/download/article.pdf).
