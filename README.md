[![Build Status](https://travis-ci.org/antoinechampion/optional.svg?branch=master)](https://travis-ci.org/antoinechampion/optional) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/optional)](https://cran.r-project.org/package=optional) ![CRAN\ Downloads](https://cranlogs.r-pkg.org/badges/optional)
<br/>https://www.antoinechampion.com/

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head>

<meta charset="utf-8">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="pandoc" />

<meta name="viewport" content="width=device-width, initial-scale=1">

</head>

<body><div id="MathJax_Message" style="display: none;"></div>




<h1 class="title toc-ignore">User Guide</h1>
<h4 class="author"><em>Antoine Champion</em></h4>
<h4 class="date"><em>2018-11-20</em></h4>



<section id="introduction" class="level2">
  <h2>Introduction</h2>
  <p>This package adds an <code>optional</code> type, similar to <code>Option</code> in F#, OCaml and Scala, to <code>Maybe</code> in Haskell, and to nullable types in <code>C#</code>.</p>
  <p>It should be used instead of <code>NULL</code> for values that might be missing or otherwise invalid.</p>
  <p>This package also introduces pattern matching.</p>
</section>
<section id="using-the-optional-type" class="level2">
  <h2>Using the optional type</h2>
  <p><code>option</code> is an object wrapper which indicates whether the object is valid or not.</p>
  <section id="declaring-an-optional-object" class="level3">
    <h3>Declaring an optional object</h3>
    <p>An optional variable can be set to <code>option(object)</code> or to <code>none</code>.</p>
    <div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1">a &lt;-<span class="st"> </span><span class="kw">option</span>(<span class="dv">5</span>)</a>
<a class="sourceLine" id="cb1-2" title="2"><span class="kw">class</span>(a)</a></code></pre></div>
    <pre><code>## [1] "optional"</code></pre>
    <p>Operators and print will have the same behavior with an <code>optional</code> than with its base type.</p>
    <div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" title="1">a <span class="op">==</span><span class="st"> </span><span class="dv">5</span></a></code></pre></div>
    <pre><code>## [1] TRUE</code></pre>
    <div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1">a</a></code></pre></div>
    <pre><code>## [1] 5</code></pre>
    <p>Note that <code>option(option(obj))</code> equals <code>option(obj)</code> and that <code>option(none)</code> equals <code>FALSE</code>.</p>
    <p>To check whether an <code>optional</code> object is set to a value or to <code>none</code>, one can use the function <code>some()</code>.</p>
    <div class="sourceCode" id="cb7"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb7-1" title="1">a &lt;-<span class="st"> </span><span class="kw">option</span>(<span class="dv">5</span>)</a>
<a class="sourceLine" id="cb7-2" title="2"><span class="kw">some</span>(a)</a></code></pre></div>
    <pre><code>## [1] TRUE</code></pre>
    <div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" title="1">a &lt;-<span class="st"> </span>none</a>
<a class="sourceLine" id="cb9-2" title="2"><span class="kw">some</span>(a)</a></code></pre></div>
    <pre><code>## [1] FALSE</code></pre>
  </section>
  <section id="optionals-on-functions" class="level3">
    <h3>Optionals on functions</h3>
    <p>Given a function <code>f()</code>, to handle properly <code>optional</code> arguments and wraps its return type into an <code>optional</code>, one should use <code>make_opt()</code> the following way:</p>
    <pre><code>f_opt &lt;- make_opt(f)</code></pre>
    <ol type="1">
      <li>Every <code>optional</code> argument passed to <code>f_opt()</code> will be converted to its original type before being sent to <code>f()</code>. If one or more of them is <code>none</code>, several behaviors are available (see <code>?make_opt</code>).</li>
      <li>If <code>f()</code> returns null, or if an error is thrown during its execution, then <code>f_opt()</code> returns <code>none</code>. Else it will return <code>optional(f(...))</code>.</li>
    </ol>
    <p>For instance:</p>
    <div class="sourceCode" id="cb12"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb12-1" title="1">c_opt &lt;-<span class="st"> </span><span class="kw">make_opt</span>(c)</a>
<a class="sourceLine" id="cb12-2" title="2"><span class="kw">c_opt</span>(<span class="kw">option</span>(<span class="dv">2</span>), none, <span class="kw">option</span>(<span class="dv">5</span>))</a></code></pre></div>
    <pre><code>## [1] 2 5</code></pre>
    <div class="sourceCode" id="cb14"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb14-1" title="1"><span class="kw">c_opt</span>()</a></code></pre></div>
    <pre><code>## [1] "None"</code></pre>
  </section>
</section>
<section id="pattern-matching" class="level2">
  <h2>Pattern matching</h2>
  <p>Patterns are used in many functional languages in order to process variables in an exhaustive way.</p>
  <p>The syntax is the following:</p>
  <pre><code>match_with( variable,
pattern , result-function,
...</code></pre>
  <p>If <code>variable</code> matches a <code>pattern</code>, <code>result-function</code> is called. For comparing optional types, it is a better habit to use <code>match_with()</code> rather than a conditional statement.</p>
  <div class="sourceCode" id="cb17"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb17-1" title="1"><span class="kw">library</span>(magrittr)</a>
<a class="sourceLine" id="cb17-2" title="2"></a>
<a class="sourceLine" id="cb17-3" title="3">a &lt;-<span class="st"> </span><span class="dv">5</span></a>
<a class="sourceLine" id="cb17-4" title="4"><span class="kw">match_with</span>(a,</a>
<a class="sourceLine" id="cb17-5" title="5">  . <span class="op">%&gt;%</span><span class="st"> </span><span class="kw">option</span>(.),          paste,</a>
<a class="sourceLine" id="cb17-6" title="6">  none,                   <span class="cf">function</span>() <span class="st">"Error!"</span></a>
<a class="sourceLine" id="cb17-7" title="7">)</a></code></pre></div>
  <pre><code>## [1] "5"</code></pre>
  <ol type="1">
    <li>Each <code>pattern</code> can be either:
      <ul>
        <li>an object or a primitive type (direct comparison with <code>variable</code>),</li>
        <li>a list (match if <code>variable</code> is in the list),</li>
        <li>a <code>magrittr</code> functional sequence that matches if it returns <code>variable</code>. The dot <code>.</code> denotes the variable to be matched.</li>
      </ul></li>
    <li>If <code>result-function</code> takes no arguments, it will be called as is. Else, the only argument that will be sent is <code>variable</code>. You can also use the fallthrough function <code>fallthrough()</code> to permit the matching to continue even if the current pattern is matched.</li>
  </ol>
  <div class="sourceCode" id="cb19"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb19-1" title="1">a &lt;-<span class="st"> </span><span class="dv">4</span></a>
<a class="sourceLine" id="cb19-2" title="2"><span class="kw">match_with</span>(a,</a>
<a class="sourceLine" id="cb19-3" title="3">  <span class="dv">1</span>,                 <span class="cf">function</span>() <span class="st">"Matched exact value"</span>,</a>
<a class="sourceLine" id="cb19-4" title="4">  <span class="kw">list</span>(<span class="dv">2</span>, <span class="dv">3</span>, <span class="dv">4</span>),     <span class="kw">fallthrough</span>(<span class="cf">function</span>() <span class="st">"Matched in list"</span>),</a>
<a class="sourceLine" id="cb19-5" title="5">  . <span class="op">%&gt;%</span><span class="st"> </span><span class="cf">if</span> (. <span class="op">&gt;</span><span class="st"> </span><span class="dv">3</span>)., <span class="cf">function</span>(x) <span class="kw">paste0</span>(<span class="st">"Matched in condition: "</span>,x,<span class="st">"&gt;3"</span>)</a>
<a class="sourceLine" id="cb19-6" title="6">)</a></code></pre></div>
  <pre><code>## [1] "Matched in list"           "Matched in condition: 4&gt;3"</code></pre>
</section>



<!-- dynamically load mathjax for compatibility with self-contained -->
<script>
  (function () {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src  = "https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML";
    document.getElementsByTagName("head")[0].appendChild(script);
  })();
</script>



</body>
</html>
