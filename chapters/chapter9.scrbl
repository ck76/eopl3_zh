#lang scribble/book
@(require "style.rkt"
          latex-utils/scribble/math
          latex-utils/scribble/utils
          scribble/manual
          scribble-math
          scribble/example
          scribble/core
          scribble/example
          scriblib/footnote
          racket/sandbox)

@title[#:style 'numbered #:tag "oac"]{对象和类}

许多编程任务都需要程序通过接口管理某些状态。例如，文件系统有内部状态，但访问和修
改那一状态只能通过文件系统的接口。状态常常涉及多个变量，为了维护状态的一致性，必
须协同修改那些变量。因此，需要某种技术，确保组成状态的多个变量能协同更新。
@emph{面向对象编程} (@emph{Object-oriented programming})正是用来完成此任务的技术。

在面向对象编程中，每种受管理的状态称为一个@emph{对象} (@emph{object})。一个对象
中存有多个量，称为@emph{字段} (@emph{field})；有多个相关过程，称为@emph{方法}
(@emph{method})，方法能够访问字段。调用方法常被视为将方法名和参数当作消息传给对
象；有时，又说这是从@emph{消息传递} (@emph{message-psasing})的视角看待面向对象编
程。

在@secref{state}那样的有状态语言中，过程就是用对象编程的绝佳示例。过程是一种对象，
其状态包含在自由变量之中。闭包只有一种行为：用某些参数调用它。例如，
@elem[#:style question]{105页}的@tt{g}控制计数器的状态，对这一状态，唯一能做的就
是将其递增。但是，更常见的是让一个对象具有多种行为。面向对象编程语言提供这种功能。

同一方法常常需要管理多重状态，例如多个文件系统或程序中的多个队列。为便于方法共享，
面向对象编程系统通常提供名为@emph{类} (@emph{class})的结构，用来指定某种对象的字
段及方法。每个对象都创建为类的@emph{实例} (@emph{instance})。

类似地，多个类可能有相似而不相同的字段和方法。为便于共享实现，面向对象编程语言通
常提供@emph{继承} (@emph{inheritance})，允许程序员增改某些方法的行为，添加字段，
对现有类小做修改，就能定义新类。这时，由于新类的其他行为从原类继承而得，我们说新
类@emph{继承于} (@emph{inherit from})或@emph{扩展} (@emph{extend})旧类。

不论程序元素是在建模真实世界中的对象还是人为层面的系统状态，都要弄清楚，程序结构
能否由结合行为和状态的对象组成。将行为类似的对象与同一个类关联起来，也是自然而然
的。

真实世界中的对象通常具有某种@emph{状态}和@emph{行为}，后者要么控制前者，要么受前
者控制。例如，猫能吃，打呼噜，跳和躺下，这些活动都由猫当前的状态控制，包括它们有
多饿，有多累。

对象和模块颇多相似，但又截然不同。模块和类都提供了定义模糊类型的机制。但对象是一
种有行为的数据结构，模块只是一组绑定。同一个类可以有很多个对象；大多数模块系统没
有提供相仿的能力。但是，PROC-MODULES这样的模块系统提供了更为灵活的方式来控制名字
的可见性。模块和类可以相得益彰。

@section[#:tag "s9.1"]{面向对象编程}

本章，我们研究一种简单的面向对象编程语言，名为CLASSES。CLASSES程序包含一些类声明，
然后是一个可能用到那些类的表达式。

图9.1展示了这种语言的一个简单程序。它定义了继承于@tt{object}的类@tt{c1}。类
@tt{c1}的每个对象都包含两个字段，名为@tt{i}和@tt{j}。字段叫做@emph{成员}
(@emph{member})或@emph{实例变量} (@emph{instance variable})。类@tt{c1}支持三个
@emph{方法}或@emph{成员函数} (@emph{member function})，名为 @tt{initialize}、
@tt{countup}和@tt{getstate}。每个方法包含@emph{方法名} (@emph{method name})，若
干@emph{方法变量} (@emph{method var})（又称 @emph{方法参数} (@emph{method
parameters})），以及 @emph{方法主体} (@emph{method body})。方法名对应于@tt{c1}的
实例能够响应的@emph{消息}种类。有时，我们说成是“@tt{c1}的方法@tt{countup}”。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class c1 extends object
 field i
 field j
 method initialize (x)
  begin
   set i = x;
   set j = -(0,x)
  end
 method countup (d)
  begin
   set i = +(i,d);
   set j = -(j,d)
  end
 method getstate () list(i,j)
let t1 = 0
    t2 = 0
    o1 = new c1(3)
in begin
    set t1 = send o1 getstate();
    send o1 countup(2);
    set t2 = send o1 getstate();
    list(t1,t2)
   end
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "简单的面向对象程序"))]
}


本例中，类的每个方法都维护完整性约束或@emph{不变式}@${i = -j}。当然，现实中程序
例子的完整性约束可能复杂得多。

图9.1中的程序首先初始化三个变量。@tt{t1}和@tt{t2}初始化为0。@tt{o1}初始化为
@tt{c1}的一个对象。我们说这个对象是类@tt{c1}的一个@emph{实例}。对象通过操作
@tt{new}创建。它会触发调用类的方法@tt{initialize}，在本例中，是将对象的字段
@tt{i}设置为3，字段@tt{j}设置为-3。然后，程序调用@tt{o1}的方法@tt{getstate}，返
回列表@tt{(3 -3)}。接着，它调用@tt{o1}的方法@tt{countup}，将两个字段的值改为5和-5。
然后再次调用@tt{getstate}，返回@tt{(5 -5pt)}。最后，值@tt{list(t1,t2)}，即
@tt{((3 -3) (5 -5))}成为整段程序的返回值。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class interior-node extends object
 field left
 field right
 method initialize (l, r)
  begin
   set left = l;
   set right = r
  end
 method sum () +(send left sum(),send right sum())
class leaf-node extends object
 field value
 method initialize (v) set value = v
 method sum () value
let o1 = new interior-node(
          new interior-node(
           new leaf-node(3),
           new leaf-node(4)),
          new leaf-node(5))
in send o1 sum()
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "求树叶之和的面向对象程序"))]
}

图9.2解释了面向对象编程中的关键思想：@emph{动态分发} (@emph{dynamic dispatch})。
在这段程序中，我们的树有两种节点，@tt{interior-node}和@tt{leaf-node}。通常，我们
不知道是在给哪种节点发消息。相反，每个节点接受@tt{sum}消息，并用自身的@tt{sum}方
法做适当操作。这叫做@emph{动态分发}。这里，表达式生成一棵树，有两个内部节点，三
个叶子节点。它将@tt{sum}消息发给节点@tt{o1}；@tt{o1}将@tt{sum}消息发给子树，依此
类推，最终返回12。这段程序也展示了，所有方法都是互递归的。

方法主体可通过标识符@tt{self}（有时叫做@tt{this}）调用同一对象的其他方法，
@tt{self}总是绑定于方法调用时的对象。例如，在

@nested{
@nested[#:style 'code-inset]{
@verbatim|{
class oddeven extends object
 method initialize () 1
 method even (n)
  if zero?(n) then 1 else send self odd(-(n,1))
 method odd (n)
  if zero?(n) then 0 else send self even(-(n,1))
let o1 = new oddeven()
in send o1 odd(13)}|
}

中，方法@tt{even}和@tt{odd}递归调用彼此，因为它们执行时，@tt{self}绑定到包含二者
的对象。这就像练习3.37中，用动态绑定实现递归。
}

@section[#:tag "s9.2"]{继承}

通过继承，程序员能够逐步修改旧类，得到新类。在实践中，这十分有用。例如，有颜色的
点类似一个点，但是它还有处理颜色的方法，如图9.3中的经典例子所示。

如果类@${c_2}扩展类@${c_1}，我们说@${c_1}是@${c_2}的@emph{父类} (@emph{parent})
或@emph{超类} (@emph{superclass})，@${c_2}是@${c_1}的@emph{子类} (@emph{child})。
继承时，由于@${c_2}定义为@${c_1}的扩展，@${c_1}必须在@${c_2}之前定义。在此之前，
语言包含了一个预先定义的类，名为@tt{object}，它没有任何方法或字段。由于类
@tt{object}没有@tt{initialize}方法，因此无法创建它的对象。除@tt{object}之外的所
有类都有唯一父类，但可以有许多子类。因此，由@tt{extends}得出的关系在类与类之间产
生了树状结构，其根为@tt{object}。因为每个类至多只有一个直接超类，这是一种
@emph{单继承} (@emph{single-inheritance})语言。有些语言允许类继承自多个超类。
@emph{多继承} (@emph{multiple inheritance})虽然强大，却不无问题。在练习中，我们
考虑一些困难之处。

术语@emph{继承}源于对宗谱的类比。我们常常引申这一类比，说类的@emph{祖先}
(@emph{ancestor})（从类的父类到根部的类@tt{object}）和@emph{后代}
(@emph{descendant})。如果@${c_2}是@${c_1}的后代，我们有时说@${c_2}是@${c_1}的
@emph{子类} (@emph{subclass})，写作@${c_2 < c_1}。

如果类@${c_2}继承自类@${c_1}，@${c_1}的所有字段和方法都对@${c_2}的方法可见，除非
在@${c_2}中重新声明它们。由于一个类继承了父类的所有方法和字段，子类的实例可以在
任何能够使用父类实例的地方使用。类似地，类后代的实例可以在任何能够使用类实例的地
方使用。有时，这叫做@emph{子类多态} (@emph{subclass polymorphism})。我们的语言选
择这种设计，其他面向对象语言可能有不同的可见性规则。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class point extends object
 field x
 field y
 method initialize (initx, inity)
  begin
   set x = initx;
   set y = inity
  end
 method move (dx, dy)
  begin
   set x = +(x,dx);
   set y = +(y,dy)
  end
 method get-location () list(x,y)
class colorpoint extends point
 field color
 method set-color (c) set color = c
 method get-color () color
let p = new point(3,4)
    cp = new colorpoint(10, 20)
in begin
    send p move(3,4);
    send cp set-color(87);
    send cp move(10,20);
    list(send p get-location(),   % |@emph{返回} (6 8)
         send cp get-location(),  % |@emph{返回} (20 40)
         send cp get-color())     % |@emph{返回} 87
   end
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "继承的经典例子：" @tt{colorpoint}))]
}

接下来，我们看看重新声明类的字段或方法时会发生什么。如果@${c_1}的子读在子类
@${c_2}中重新声明，新的声明@emph{遮蔽} (@emph{shadow})旧的，就像词法定界一样。例
如，考虑图9.4。类@tt{c2}的对象有两个名为@tt{y}的字段：@tt{c1}中声明的和@tt{c2}中
声明的。@tt{c1}中声明的方法能看到@tt{c1}的字段@tt{x}和@tt{y}。在@tt{c2}中，
@tt{getx2}中的@tt{x}指代@tt{c1}的字段@tt{x}，但@tt{gety2}中的@tt{y}指代@tt{c1}的
字段@tt{y}。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class c1 extends object
 field x
 field y
 method initialize () 1
 method setx1 (v) set x = v
 method sety1 (v) set y = v
 method getx1 () x
 method gety1 () y
class c2 extends c1
 field y
 method sety2 (v) set y = v
 method getx2 () x
 method gety2 () y
let o2 = new c2()
in begin
    send o2 setx1(101);
    send o2 sety1(102);
    send o2 sety2(999);
    list(send o2 getx1(),  % |@emph{返回} 101
         send o2 gety1(),  % |@emph{返回} 102
         send o2 getx2(),  % |@emph{返回} 101
         send o2 gety2())  % |@emph{返回} 999
   end
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "字段遮蔽的例子"))]
}

如果类@${c_1}的方法@${m}在某个子类@${c_2}中重新声明，我们说新的方法@emph{覆盖}
(@emph{override})旧的方法。我们将方法声明所在的类称为方法的@emph{持有类}
(@emph{host class})。同样地，我们将表达式的持有类定义为表达式所在方法（如果有的
话）的持有类。我们还将方法或表达式的超类定义为持有类的父类。

如果给类@${c_2}的对象发送消息@${m}，应使用新的方法。这条规则很简单，其结果却很微
妙。考虑如下例子：

@nested{
@nested[#:style 'code-inset]{
@verbatim|{
class c1 extends object
 method initialize () 1
 method m1 () 11
 method m2 () send self m1()
class c2 extends c1
 method m1 () 22
let o1 = new c1() o2 = new c2()
in list(send o1 m1(), send o2 m1(), send o2 m2())
}|
}

我们希望@tt{send o1 m1()}返回11，因为@tt{o1}是@tt{c1}的实例。同样地，我们希望
@tt{send o2 m1()}返回22，因为@tt{o2}是@tt{c2}的实例。那么@tt{send o2 m2()}呢？方
法@tt{m2}只是调用方法@tt{m1}，但这是哪一个？
}

动态分发告诉我们，应查看绑定到@tt{self}的对象属于哪个类。@tt{self}的值是@tt{o2}，
属于类@tt{c2}。因此，调用@tt{send self m1()}应返回22。

我们的语言还有一个重要特性，@emph{超类调用} (@emph{super call})。考虑图9.5中的程
序。其中，我们在类@tt{colorpoint}中重写了@tt{initialize}方法，同时设置字段@tt{x}、
@tt{y}和@tt{color}。但是，新方法的主体复制了原方法的代码。在我们的小例子中，这尚
可接受，但在大型例子中，这显然是一种坏的做法。（为什么？）而且，如果
@tt{colorpoint}声明了字段@tt{x}，就没法初始化@tt{point}的字段@tt{x}，就像
@elem[#:style question]{331页}的例子中，没法初始化第一个@tt{y}一样。

解决方案是，把@tt{colorpoint}的@tt{initialize}方法主体中的重复代码替换为@emph{超
类调用}，形如@tt{super initialize()}。那么@tt{colorpoint}中的@tt{initialize}方法
写作：

@nested[#:style 'code-inset]{
@verbatim|{
method initialize (initx, inity, initcolor)
 begin
  super initialize(initx, inity);
  set color = initcolor
 end
}|
}

方法@${m}主体中的超类调用@tt{super @${n}(...)}使用的是@${m}持有类父类的方法@${n}。
这不一定是@tt{self}所指类的父类。@tt{self}所指类总是@${m}持有类的子类，但不一定
是同一个，@note{任何类都是自身的子类，故有此说。——@emph{译注}}因为@${m}可能在目
标对象的某个祖先中声明。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class point extends object
 field x
 field y
 method initialize (initx, inity)
  begin
   set x = initx;
   set y = inity
 end
 method move (dx, dy)
  begin
   set x = +(x,dx);
   set y = +(y,dy)
  end
 method get-location () list(x,y)
class colorpoint extends point
 field color
 method initialize (initx, inity, initcolor)
  begin
   set x = initx;
   set y = inity;
   set color = initcolor
  end
 method set-color (c) set color = c
 method get-color () color
let o1 = new colorpoint(3,4,172)
in send o1 get-color()}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "演示" @tt{super} "必要性的例子"))]
}

要解释这种区别，考虑图9.6。给类@tt{c3}的对象@tt{o3}发送消息@tt{m3}，找到的是
@tt{c2}的方法@tt{m3}，它执行@tt{super m1()}。@tt{o3}的类是@tt{c3}，其父类是
@tt{c2}，但方法的持有类是@tt{c2}，@tt{c2}的超类是@tt{c1}。所以，执行的是@tt{c1}
的方法@tt{m1}。这是@emph{静态方法分发} (@emph{static method dispatch})的例子。虽
然进行超类方法调用的对象是@tt{self}，方法分发却是静态的，因为要使用的方法可以从
程序文本中判断，与@tt{self}所指类无关。

本例中，@tt{c1}的方法@tt{m1}调用@tt{o3}的方法@tt{m2}。这是普通方法调用，所以使用
动态分发，找出的是@tt{c3}的方法@tt{m2}，返回33。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class c1 extends object
 method initialize () 1
 method m1 () send self m2()
 method m2 () 13
class c2 extends c1
 method m1 () 22
 method m2 () 23
 method m3 () super m1()
class c3 extends c2
 method m1 () 32
 method m2 () 33
let o3 = new c3()
in send o3 m3()
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "解释" @tt{super} "调用与" @tt{self} "相互作用的例子"))]
}

@section[#:tag "s9.3"]{语言}

我们的语言CLASSES由IMPLICIT-REFS扩展而得，新增生成式如图9.7所示。程序中首先是一
些类声明，然后是一个待执行的表达式。类声明有名字，最接近的超类名，0个或多个字段
声明，以及0个或多个方法声明。方法声明类似@tt{letrec}中的过程声明，有个名字，一个
形参列表，以及主体。同时我们扩展语言，支持多参数过程，多声明@tt{let}和多声明
@tt{letrec}表达式，还有些其他操作，如加法和@tt{list}。列表操作同练习3.9。最后，
我们增加@tt{begin}表达式，同练习4.4，它从左到右求出子表达式的值，返回最后一个的
值。

我们新增表达值对象和列表，所以有

@nested{

@envalign*{
\mathit{ExpVal} &= \mathit{Int} + \mathit{Bool} + \mathit{Proc} + \mathit{Listof(ExpVal)} + \mathit{Obj}\\
\mathit{DenVal} &= \mathit{Ref(ExpVal)}
}

我们写@${\mathit{Listof(ExpVal)}}，表示列表可以包含任何表达值。

}

我们将在@secref{s9.4.1}考察@${\mathit{Obj}}。在我们的语言中，类既不是指代值，也
不是表达值：它们作为对象的一部分，但不能做变量的绑定或表达式的值，不过，看看练习
9.29。

@nested[#:style eopl-figure]{

@envalign*{
           \mathit{Program} &::= \{\mathit{ClassDecl}\}^{*} \phantom{x} \mathit{Expression} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{a-program (class-decls body)}} \\[5pt]
         \mathit{ClassDecl} &::= @tt{class @m{\mathit{Identifier}} extends @m{\mathit{Identifier}}} \\[-3pt]
          &\mathrel{\phantom{::=}} \phantom{x}\{@tt{field @m{\mathit{Identifier}}}\}^{*}\phantom{x}\{\mathit{MethodDecl}\}^{*} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{\begin{math}\begin{alignedat}{-1}
                                          &@tt{a-class-decl} \\
                                          &\phantom{x}@tt["("]@tt{class-name super-name} \\
                                          &\phantom{xx}@tt{field-names method-decls}@tt[")"]
                                         \end{alignedat}\end{math}} \\[5pt]
        \mathit{MethodDecl} &::= @tt{method @m{\mathit{Identifier}} (@m{\{\mathit{Identifier}\}^{*(,)}}) @m{\mathit{Expression}}} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{a-method-decl (method-name vars body)}} \\[5pt]
        \mathit{Expression} &::= @tt{new @m{\mathit{Identifier}} (@m{\{\mathit{Expression}\}^{*(,)}})} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{new-object-exp (class-name rands)}} \\[5pt]
        \mathit{Expression} &::= @tt{send @m{\mathit{Expression}} @m{\mathit{Identifier}} (@m{\{\mathit{Expression}\}^{*(,)}})} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{method-call-exp (obj-exp method-name rands)}} \\[5pt]
        \mathit{Expression} &::= @tt{super @m{\mathit{Identifier}} (@m{\{\mathit{Expression}\}^{*(,)}})} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{super-call-exp (method-name rands)}} \\[5pt]
        \mathit{Expression} &::= @tt{self} \\[-3pt]
          &\mathrel{\phantom{::=}} \fbox{@tt{self-exp}}
          }

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "简单面向对象语言中新增的生成式"))]
}

我们新增了四种表达式。@tt{new}表达式创建指定类的对象，然后调用@tt{initialize}方
法初始化对象的字段。@tt{rands}求值后，传给@tt{initialize}方法。这个方法调用的返
回值直接抛弃，新对象则作为@tt{new}表达式的值返回。

@tt{self}表达式返回当前方法操作的对象。

@tt{send}表达式包含一值为对象的表达式，一个方法名，0或多个操作数。它从对象的类中
取出指定的方法，然后求操作数的值，将实参传给该方法。就像在IMPLICIT-REFS中那样，
它要为每个实参分配一个新位置，然后将方法的形参与对应位置的引用绑定起来，并在这个
词法绑定的作用范围内求方法主体的值。

@tt{super-call}表达式包含一个方法名，0或多个参数。它从表达式持有类的超类开始，找
出指定的方法，然后以当前对象为@tt{self}，求出方法主体的值。

@section[#:tag "s9.4"]{解释器}

求程序的值时，所有类声明都用@tt{initialize-class-env!}处理，随后求表达式的值。过
程@tt{initialize-class-env!}创建一个全局@emph{类环境} (@emph{class environment})，
将类名映射到类的方法。因为这个环境是全局的，我们用一个Scheme变量表示它。在
@secref{s9.4.3}我们再详细讨论类环境。

@racketblock[
@#,elem{@bold{@tt{value-of-program}} : @${\mathit{Program} \to \mathit{ExpVal}}}
(define value-of-program
  (lambda (pgm)
    (initialize-store!)
    (cases program pgm
      (a-program (class-decls body)
        (initialize-class-env! class-decls)
        (value-of body (init-env))))))
]

像之前那样，语言中的各种表达式在过程@tt{value-of}里都有对应的从句，也包括四种新
的生成式。

我们依次考虑新增的每种表达式。

通常，表达式需要求值，是因为它是操作某个对象的方法的一部分。在环境中，这个对像绑
定到伪变量@tt{%self}。我们称之为@emph{伪变量} (@emph{pseudo-variable})，因为它虽
然像普通变量那样遵循词法绑定，但却像下面将要探讨的那样，具有一些独特性质。类似地，
当前方法持有类的超类名字绑定到伪变量@tt{%super}。

求@tt{self}表达式的值时，返回的是@tt{%self}的值。这句话在@tt{value-of}中写作

@codeblock[#:indent 7]{
(self-exp ()
  (apply-env env '%self))
}

求@tt{send}表达式的值时，需要求操作数和对象表达式的值。我们从对象中找出它的类名，
然后用@tt{find-method}找出方法。@tt{find-method}取一类名，一方法名，返回一方法。
接着，我们用当前对象和方法参数调用这个方法。

@codeblock[#:indent 7]{
(method-call-exp (obj-exp method-name rands)
  (let ((args (values-of-exps rands env))
        (obj (value-of obj-exp env)))
    (apply-method
      (find-method
        (object->class-name obj)
        method-name)
      obj
      args)))
}

超类调用与普通方法调用类似，不同之处是，要在表达式持有类的超类中查找方法。
@tt{value-of}中的语句是

@codeblock[#:indent 7]{
(super-call-exp (method-name rands)
  (let ((args (values-of-exps rands env))
        (obj (apply-env env ’%self)))
    (apply-method
      (find-method (apply-env env ’%super) method-name)
      obj
      args)))
}

我们的最后一项工作是创建对象。求@tt{new}表达式的值时，需要求操作数的值，并根据类
名创建一个新对象。然后，调用对象的初始化函数，但要忽略这个函数的值。最后，返回该
对象。

@codeblock[#:indent 7]{
(new-object-exp (class-name rands)
  (let ((args (values-of-exps rands env))
        (obj (new-object class-name)))
    (apply-method
      (find-method class-name ’initialize)
      obj
      args)
    obj))
}

接下来，我们决定如何表示对象、方法和类。我们通过一个示例解释这种表示，如图9.8所
示。

@nested[#:style eopl-figure]{
@nested[#:style 'code-inset]{
@verbatim|{
class c1 extends object
 field x
 field y
 method initialize ()
  begin
   set x = 11;
   set y = 12
  end
 method m1 () ... x ... y ...
 method m2 () ... send self m3() ...
class c2 extends c1
 field y
 method initialize ()
  begin
   super initialize();
   set y = 22
  end
 method m1 (u,v) ... x ... y ...
 method m3 () ...
class c3 extends c2
 field x
 field z
 method initialize ()
  begin
   super initialize();
   set x = 31;
   set z = 32
  end
 method m3 () ... x ... y ... z ...
let o3 = new c3()
in send o3 m1(7,8)
}|
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "OOP实现的示例程序"))]
}

@nested[#:style eopl-figure]{
@centered{
@(image "../images/simple-object"
  #:suffixes (list ".pdf" ".svg")
  "简单对象")
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "简单对象"))]
}

@subsection[#:tag "s9.4.1"]{对象}

我们用包含类名和字段引用的数据类型表示对象。

@racketblock[
(define-datatype object object?
  (an-object
    (class-name identifier?)
    (fields (list-of reference?))))
]

在列表中，我们把“最老”类的字段排在前面。这样，在图9.8中，类@tt{c1}对象的字段排
列为@tt{(x y)}；类@tt{c2}对象的字段排列为@tt{(x y y)}，其中，第二个@tt{y}是
@tt{c2}中的；类@tt{c3}对象的字段排列为@tt{(x y y x z)}。图9.8中对象@tt{o3}的表示
如图9.9所示。当然，我们想让类@tt{c3}中的方法使用@tt{c3}中声明的字段@tt{x}，而不
是@tt{c1}中声明的。我们在建立方法主体的求值环境时处理这点。

这种方式有一条有用的性质：对@tt{c3}的任何子类，列表中同样位置具有同样的字段，因
为随后添加的任何字段都会出现在这些字段的右边。在@tt{c3}任一子类定义的某个方法中，
@tt{x}在什么位置呢？我们知道，在所有这些方法中，如果@tt{x}没有重新定义，@tt{x}的
位置一定是3。那么，当声明字段变量时，对应值的位置保持不变。与@secref{s3.6}处理变
量时类似，这条性质使我们能静态确定字段引用。

创建新方法很容易。我们只需用新引用列表创建一个@tt{an-object}，其长度与对象字段数
目相等。要确定其数目，我们从对象所属类中取出字段变量列表。我们用一个非法值初始化
每个位置，以便得知程序对未初始化位置索值。

@racketblock[
@#,elem{@${\mathit{ClassName} = \mathit{Sym}}}

@#,elem{@bold{@tt{new-object}} : @${\mathit{ClassName} \to \mathit{Obj}}}
(define new-object
  (lambda (class-name)
    (an-object
      class-name
      (map
        (lambda (field-name)
          (newref (list ’uninitialized-field field-name)))
        (class->field-names (lookup-class class-name))))))
]

@subsection[#:tag "s9.4.2"]{方法}

接下来我们处理方法。方法就像过程，但是它们不存储环境。相反，它们记录引用字段的名
字。当调用方法时，它在如下环境中执行其主体

@itemlist[

 @item{方法的形参绑定到新引用，引用初始化为实参的值。这与IMPLICIT-REFS中的
 @tt{apply-procedure}行为类似。}

 @item{伪变量@tt{%self}和@tt{%super}分别绑定到当前对象和方法的超类。}

 @item{可见的字段名绑定到当前对象的字段。要实现这点，我们定义

@racketblock[
(define-datatype method method?
  (a-method
    (vars (list-of identifier?))
    (body expression?)
    (super-name identifier?)
    (field-names (list-of identifier?))))

@#,elem{@bold{@tt{apply-method}} : @${\mathit{Method} \times \mathit{Obj} \times \mathit{Listof(ExpVal)} \to \mathit{ExpVal}}}
(define apply-method
  (lambda (m self args)
    (cases method m
      (a-method (vars body super-name field-names)
        (value-of body
          (extend-env* vars (map newref args)
            (extend-env-with-self-and-super
              self super-name
              (extend-env* field-names (object->fields self)
                (empty-env)))))))))
]
 }

]

这里，我们用练习2.10中的@tt{extend-env*}，扩展环境时，把变量列表绑定到指代值的列
表。我们还给环境接口新增过程@tt{extend-env-with-self-and-super}，分别将
@tt{%self}和@tt{%super}绑定到对象和类名。

要确保各方法看到正确的字段，我们构建@tt{field-names}列表时要小心。各方法只应见到
最后一个声明的同名字段，其他同名字段应被遮蔽。所以，我们构建@tt{field-names}列表
时，将把最右边之外的出现的每个名字替换为新名。对图9.8中的程序，得出的
@tt{field-names}如下

@nested{

@tabular[#:sep @hspace[4]
         (list (list @bold{类} @bold{定义的字段} @bold{字段}      @bold{@tt{field-names}})
               (list @tt{c1}   @tt{x, y}         @tt{(x y)}       @tt{(x@${\phantom{xxx}}y)})
               (list @tt{c2}   @tt{y}            @tt{(x y y)}     @tt{(x@${\phantom{xxx}}y%1 y)})
               (list @tt{c3}   @tt{x, z}         @tt{(x y y x z)} @tt{(x%1@${\phantom{x}}y%1 y x z)}))]

由于方法主体对@tt{x%1}和@tt{y%1}一无所知，所以对各字段变量，它们只能见到最右边的。

}

图9.10展示了求值图9.8中方法主体内的@tt{send o3 m1(7,8)}时创建的环境。这张图表明，
引用列表可能比变量列表长：变量列表只是@tt{(x y%1 y)}，因为从@tt{c2}的方法@tt{m1}
中只能见到这些字段变量，但@tt{(object->fields self)}的值是对象中所有字段的列表。
不过，由于三个可见字段变量的值是列表中的头三个元素，而且我们把第一个@tt{y}重命名
为@tt{y%1}（该方法对词一无所知），方法@tt{m1}将把变量@tt{y}与@tt{c2}中声明的
@tt{y}关联起来，正符期望。

@nested[#:style eopl-figure]{
@centered{
@(image "../images/env-for-method"
  #:scale 0.95
  #:suffixes (list ".pdf" ".svg")
  "方法调用时的环境")
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "方法调用时的环境"))]
}

当@tt{self}的持有类和所属类相同时，变量列表的长度通常与字段位置列表的长度相同。
如果持有类位于类链的上端，那么位置可能多于字段变量，与字段变量对应的值将位于列表
开头，其余值则不可见。

@subsection[#:tag "s9.4.3"]{类和类环境}

迄今为止，我们的实现都依赖从类名获取与类相关的信息。所以，我们需要一个@emph{类环
境} (@emph{class environment}) 完成这一工作。类环境将每个类名与描述类的数据结构
关联起来。

类环境是全局的：在我们的语言中，类声明聚集于程序开头，且对整个程序生效。所以，我
们用名为@tt{the-class-env}的全局变量表示类环境，它包含一个(类名, 类)列表的列表，
但我们用过程@tt{add-to-class-env!}和@tt{lookup-class}隐藏这一表示。

@racketblock[
@#,elem{@${\mathit{ClassEnv} = \mathit{Listof(List(ClassName, Class))}}}

@#,elem{@bold{@tt{the-class-env}} : @${\mathit{ClassEnv}}}
(define the-class-env ’())

@#,elem{@bold{@tt{add-to-class-env!}} : @${\mathit{ClassName} \times \mathit{Class} \to \mathit{Unspecified}}}
(define add-to-class-env!
  (lambda (class-name class)
    (set! the-class-env
      (cons
        (list class-name class)
        the-class-env))))

@#,elem{@bold{@tt{lookup-class}} : @${\mathit{ClassName} \to \mathit{Class}}}
(define lookup-class
  (lambda (name)
    (let ((maybe-pair (assq name the-class-env)))
      (if maybe-pair (cadr maybe-pair)
        (report-unknown-class name)))))
]

对每个类，我们记录三样东西：超类的名字，字段变量的列表，以及将方法名映射到方法的
环境。

@nested{
@racketblock[
(define-datatype class class?
  (a-class
    (super-name (maybe identifier?))
    (field-names (list-of identifier?))
    (method-env method-environment?)))
]

这里，我们用谓词@tt{(maybe identifier?)}，判断值是否为符号或@tt{#f}。后一种情况
对是必须的，因为类@tt{object}没有超类。@tt{filed-names}是类的方法能见到的字段，
@tt{method-env}是一环境，给出了类中每个方法名的定义。

}

我们初始化类环境时，为类@tt{object}添加一个绑定。对每个声明，我们向类环境添加新
的绑定，将类名绑定到一个@tt{class}，它包含超类名，类中方法的@tt{field-names}，以
及类中方法的环境。

@racketblock[
@#,elem{@bold{@tt{initialize-class-env!}} : @${\mathit{Listof(ClassDecl)} \to \mathit{Unspecified}}}
(define initialize-class-env!
  (lambda (c-decls)
    (set! the-class-env
      (list
        (list ’object (a-class #f ’() ’()))))
    (for-each initialize-class-decl! c-decls)))

@#,elem{@bold{@tt{initialize-class-decl!}} : @${\mathit{ClassDecl} \to \mathit{Unspecified}}}
(define initialize-class-decl!
  (lambda (c-decl)
    (cases class-decl c-decl
      (a-class-decl (c-name s-name f-names m-decls)
        (let ((f-names
                (append-field-names
                  (class->field-names (lookup-class s-name))
                  f-names)))
          (add-to-class-env!
            c-name
            (a-class s-name f-names
              (merge-method-envs
                (class->method-env (lookup-class s-name))
                (method-decls->method-env
                  m-decls s-name f-names)))))))))
]

过程@tt{append-field-names}用来给当前类创建@tt{field-names}。它@elem[#:style
question]{扩展}超类字段和新类声明的字段，只是将超类中被新字段遮蔽的字段替换为新
名字，就像@elem[#:style question]{341页}的例子那样。

@racketblock[
@#,elem{@bold{@tt{append-field-names}} : @linebreak[]@${\phantom{xx}}@${\mathit{Listof(FieldName)} \times \mathit{Listof(FieldName)} \to \mathit{Listof(FieldName)}}}
(define append-field-names
  (lambda (super-fields new-fields)
    (cond
      ((null? super-fields) new-fields)
      (else
        (cons
          (if (memq (car super-fields) new-fields)
            (fresh-identifier (car super-fields))
            (car super-fields))
          (append-field-names
            (cdr super-fields) new-fields))))))
]

@subsection[#:tag "s9.4.4"]{方法环境}

剩下的只有@tt{find-method}和@tt{merge-method-envs}。

像之前处理类那样，我们用(方法名, 方法)列表的列表表示方法环境，用@tt{find-method}
查找方法。

@racketblock[
@#,elem{@${\mathit{MethodEnv} = \mathit{Listof(List(MethodName, Method))}}}

@#,elem{@bold{@tt{find-method}} : @${\mathit{Sym} \times \mathit{Sym} \to \mathit{Method}}}
(define find-method
  (lambda (c-name name)
    (let ((m-env (class->method-env (lookup-class c-name))))
      (let ((maybe-pair (assq name m-env)))
        (if (pair? maybe-pair) (cadr maybe-pair)
          (report-method-not-found name))))))
]

用这条信息，我们可以写出@tt{method-decls->method-env}。它取一个类的方法声明，创
建一个方法环境，记录每个方法的绑定变量，主体，持有类的超类名，以及持有类的
@tt{field-names}。

@racketblock[
@#,elem{@bold{@tt{method-decls->method-env}} : @linebreak[]@${\phantom{xx}}@${\mathit{Listof(MethodDecl)} \times \mathit{ClassName} \times \mathit{Listof(FieldName)} \to \mathit{MethodEnv}}}
(define method-decls->method-env
  (lambda (m-decls super-name field-names)
    (map
      (lambda (m-decl)
        (cases method-decl m-decl
          (a-method-decl (method-name vars body)
            (list method-name
              (a-method vars body super-name field-names)))))
      m-decls)))
]

最后，我们写出@tt{merge-method-envs}。由于新类中的方法覆盖了旧类的同名方法，我们
可以直接扩展环境，将新方法添加到前面。

@nested{
@racketblock[
@#,elem{@bold{@tt{merge-method-envs}} : @${\mathit{MethodEnv} \times \mathit{MethodEnv} \to \mathit{MethodEnv}}}
(define merge-method-envs
  (lambda (super-m-env new-m-env)
    (append new-m-env super-m-env)))
]

还有一些方式构建的方法环境在查询方法时更高效（练习9.18）。

}

@nested[#:style eopl-figure]{
@racketblock[
((c3
   #(struct:a-class c2 (x%2 y%1 y x z)
      ((initialize #(struct:a-method ()
                      #(struct:begin-exp ...) c2 (x%2 y%1 y x z)))
        (m3 #(struct:a-method ()
               #(struct:diff-exp ...)) c2 (x%2 y%1 y x z))
        (initialize #(struct:a-method ...))
        (m1 #(struct:a-method (u v)
               #(struct:diff-exp ...) c1 (x y%1 y)))
        (m3 #(struct:a-method ...))
        (initialize #(struct:a-method ...))
        (m1 #(struct:a-method ...))
        (m2 #(struct:a-method ()
               #(struct:method-call-exp #(struct:self-exp) m3 ())
               object (x y))))))
  (c2
    #(struct:a-class c1 (x y%1 y)
       ((initialize #(struct:a-method ()
                       #(struct:begin-exp ...) c1 (x y%1 y)))
         (m1 #(struct:a-method (u v)
                #(struct:diff-exp ...) c1 (x y%1 y)))
         (m3 #(struct:a-method ()
                #(struct:const-exp 23) c1 (x y%1 y)))
         (initialize #(struct:a-method ...))
         (m1 #(struct:a-method ...))
         (m2 #(struct:a-method ()
                #(struct:method-call-exp #(struct:self-exp) m3 ())
                object (x y))))))
  (c1
    #(struct:a-class object (x y)
       ((initialize #(struct:a-method ()
                       #(struct:begin-exp ...) object (x y)))
         (m1 #(struct:a-method ()
                #(struct:diff-exp ...) object (x y)))
         (m2 #(struct:a-method ()
                #(struct:method-call-exp #(struct:self-exp) m3 ())
                object (x y))))))
  (object
    #(struct:a-class #f () ())))
]

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "图9.8中的类环境"))]
}

@subsection[#:tag "s9.4.5"]{练习}

@exercise[#:level 1 #:tag "ex9.1"]{

用本节的语言实现以下各项：

@itemlist[#:style 'ordered

 @item{队列类，包含方法@tt{empty?}、@tt{enqueue}和@tt{dequeue}。}

 @item{扩展队列类，添加计数器，记录当前队列已进行的操作数。}

 @item{扩展队列类，添加计数器，记录本类所有队列已进行的操作总数。提示：可在初始
 化时传递共享计数器。}

]

}

@exercise[#:level 1 #:tag "ex9.2"]{

继承也可以很危险，因为子类可以任意覆盖一个方法，改变其行为。定义继承自
@tt{oddeven}的类@tt{bogus-oddeven}，覆盖方法@tt{even}，从而导致@tt{let o1 = new
bogus-oddeven() in send o1 odd (13)}给出错误的答案。

}

@exercise[#:level 2 #:tag "ex9.3"]{

在图9.11中，哪里是共享的方法环境？哪里是共享的@tt{field-names}列表？

}

@exercise[#:level 1 #:tag "ex9.4"]{

修改对象的表示，让@${\mathit{Obj}}包含对象所属的类，而非其名字。跟文中的方式相比，
这有什么优势和劣势？

}

@exercise[#:level 1 #:tag "ex9.5"]{

@secref{s9.4}中的解释器在词法环境中存储方法持有类的超类名。修改实现，让方法存储
持有类的名字，然后用持有类的名字查找超类名。

}

@exercise[#:level 1 #:tag "ex9.6"]{

给我们的语言添加表达式@tt{instanceof @${exp} @${class\mbox{-}name}}。当且仅当表
达式@${exp}的值为对象，且是@${class\mbox{-}name}或其子类的实例时，这种表达式的值
为真。

}

@exercise[#:level 1 #:tag "ex9.7"]{

在我们的语言中，方法环境包含持有类@emph{以及}超类声明的字段变量的绑定。限制它，
只包含持有类的字段变量绑定。

}

@exercise[#:level 1 #:tag "ex9.8"]{

给我们的语言添加一个新表达式，

@centered{@tt{fieldref @${obj} @${field\mbox{-}name}}}

取出指定对象指定字段的内容。再添加

@centered{@tt{fieldset @${obj} @${field\mbox{-}name} = @${exp}}}

将指定字段设置为@${exp}的值。

}

@exercise[#:level 1 #:tag "ex9.9"]{

添加表达式@tt{superfieldref @${field\mbox{-}name}}和@tt{superfieldset
@${field\mbox{-}name} = @${exp}}，处理@tt{self}中被遮蔽的字段。记住，@tt{super}
是静态的，总是指持有类的超类。

}

@section[#:tag "s9.5"]{带类型的语言}

@section[#:tag "s9.6"]{类型检查器}

@nested[#:style eopl-figure]{
@centered{
@(image "../images/subtyping-proc-type"
  #:scale 1.5
  #:suffixes (list ".pdf" ".svg")
  "过程类型的子类型判定")
}

@make-nested-flow[
 (make-style "caption" (list 'multicommand))
 (list (para "过程类型的子类型判定"))]
}
