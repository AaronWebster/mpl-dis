#!/bin/bash

cat <<EOF
\begin{figure}[ht]
\centering
\pgfplotsset{
 minor tick num=3,
 small,
 every axis/.style={thick,width=0.56\textwidth,height=0.20\textwidth},
 legend style={ legend pos = north east, font = \small, draw = none},
}
\begin{tabular}{ll}
\multicolumn{1}{c}{\large \centering $|E_\text{spec}|^2$ }
&\multicolumn{1}{c}{\large \centering $|E_\text{cone}|^2$ }\\
EOF

\addlegendentry{$z=\SI{0}{\milli\meter}$}
\addplot[color=colora] file {XXXdirXXX/.dat};
\addplot[color=colorb,dashed] file {fresnel/0_gauss.dat};
%\addplot[color=colora,mark=x,mark size={0.750},only marks] file {data/near02-line-mod.txt};
\end{axis}
\end{tikzpicture}%
&
\begin{tikzpicture}[baseline,trim axis left]
\begin{axis}
\addlegendimage{empty legend}
\addlegendentry{$z=\SI{0}{\milli\meter}$}
\addplot[color=colorc] file {fresnel/00_r321.dat};
%\addplot[color=colora,mark=x,mark size={0.750},only marks] file {data/conenear-line-mod.txt};
\end{axis}
\end{tikzpicture}%
\\

\begin{tikzpicture}[baseline,trim axis left]
\begin{axis}[
xlabel=detector scale,
/pgfplots/change x base,
/pgfplots/x unit=\si{\micro\meter},
]
\addlegendimage{empty legend}
\addlegendentry{$z=\SI{23.42}{\milli\meter}$}
\addplot[color=colora] file {fresnel/20000_r123.dat};
\addplot[color=colorb,dashed] file {fresnel/20000_gauss.dat};
%\addplot[color=colorc,mark=x,mark size={0.750},only marks] file {data/farfield02-avg-mod.txt};
\end{axis}
\end{tikzpicture}%
&
\begin{tikzpicture}[baseline,trim axis left]
\begin{axis}[
xlabel=detector scale,
/pgfplots/change x base,
/pgfplots/x unit=\si{\micro\meter},
]
\addlegendimage{empty legend}
\addlegendentry{$z=\SI{23.42}{\milli\meter}$}
\addplot[color=colorc] file {fresnel/20000_r321.dat};
%\addplot[color=colorc,mark=x,mark size={0.750},only marks] file {data/farfield-cone-mod.txt};
\end{axis}
\end{tikzpicture}%
\end{tabular}
\caption{Simulated $|E_\text{spec}(x,z)|^2$ and $|E_\text{cone}(x,z)|^2$
for different propagation distances $z$.  The incident Gaussian beam
$\tilde{g}(k_x)$ has been propagated unmodified by the Fresnel term and
appears alongside $|E_\text{spec}(x,z)|^2$ as a dashed line.}
\label{fig:fresnelpropagate}
\end{figure}
