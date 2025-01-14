---
layout: post
title: Type Erasure Is A Failed Experiment - Interface Segregation
date: 2016-10-11 09:00
author: silas.reinagel@gmail.com
comments: true
categories: [blog]
featured-img: /images/pink-eraser.jpg
---

Generics are amazing! There is something immensely satisfying about solving an entire class of similar problems, rather than just solving a single instance of a problem. Why figure out how to cache this one database call, when I could figure out how to cache an arbitrary number of varying database calls? Why merely solve authenticating one web request, when a solution to authenticating all web requests is within reach? The scope of engineering problems vary, but my tendency does not. I would rather solve something abstractly, than concretely. Creating simple, elegant, portable solutions to particular type of problems is immensely satisfying.

Unfortunately, Java's generics are sorely lacking. They work in some scenarios. They help me solve some of the things I wish to do. But they also create problems. This is primarily because of the failed experiment of Type Erasure. Type erasure means that during runtime, information concerning generic parameters is forgotten. Type information generally only exists at compile time. It isn't quite as simple as that, but that's the simplest way I can express it. This creates some very interesting and problematic scenarios. 

Before we get into some code, here is an imaginary conversation I have with two different programming languages.

#### Imaginary C# conversation
```var basket = new Basket<EasterEgg>();```
<blockquote>Dev: Hey C#, how many eggs are in the basket?
C#: 5
Dev: What kind of items are in this basket?
C#: EasterEggs
Dev: Great. Thank you.</blockquote>


#### Same conversation in Java
```Basket<EasterEgg> basket = new Basket<>();```
<blockquote>Dev: Hey Java, how many eggs are in the basket?
Java: Do you mean items?
Dev: Sure, How many items are in the basket?
Java: 5
Dev: Java, what kind of items are in the basket?
Java: I don't know.
Dev: What do you mean you don't know?
Java: I forgot
Dev: Java, that's a basket of eggs, ok?
Java: Ok
Dev: What kind of items are in the basket?
Java: I don't know.
Dev: What do you mean you don't know? I just told you.
Java: I forgot.
Dev: Hey Java, can you get me a Flower out of the basket?
Java: Sure. Here's a Flower
Dev: What on earth! This is an Easter Egg! Why did you tell me it was a Flower?
Java: You asked for a Flower. That's your problem.</blockquote>


----

### Interface Segregation Troubles

----

Consider the following. Suppose we are creating an application that reports on the contents of Easter Egg Hunt findings.

```
public class EasterCollectionReport
{
    private List<String> reportLines = new ArrayList<>();
    
    public void add(EasterEgg egg)
    {
        reportLines.add("Easter Egg: " + egg.toString());
    }

    public void add(Candy candy)
    {
        reportLines.add("Candy: " + candy.toString());
    }
}
```

This compiles just fine. No problems. Now, let us suppose we want to interface segregate this Report, such that Candy does not know that this report may contain information about EasterEggs and vice versa. The clients say that sometimes they want to format the Candy report and the EasterEgg report differently, but other times they want a single simple report. So, we create a simple generic interface:

```
public interface Report<T>
{
    void add(T obj);
}
```

Now, the EasterCollectionReport should implement this interface twice, since we can presently add Candy or Easter Eggs to this report.

```
public class EasterCollectionReport implements Report<Candy>, Report<EasterEgg> { ... }
```

This no longer compiles. Your IDE will tell you that you cannot implement `Report` twice. It is a duplicate implementation. Why? Because of Type Erasure. Even though Java can use dynamic method dispatch to figure out whether the `add(candy)` or the `add(egg)` method are called, it cannot distinguish between a Report of Candy and a Report of EasterEgg. 

That's ok, we are engineers! Surely we can easily solve this minor problem! Maybe let's try giving the reports concrete names.

```
public interface CandyReport extends Report<Candy> { ... }
public interface EasterEggReport extends Report<EasterEgg> { ... }

public class EasterCollectionReport implements CandyReport, EasterEggReport { ... }
```

Nope. That doesn't work. Our helpful IDE tells us "'Report' cannot be implemented with different type arguments, 'Candy' and 'EasterEgg'". Okay, let's try something else. Maybe we can make a new interface for Report that contains two different types. 

```
public interface Report2<T1, T2>
{
    void add(T1 obj);
    void add(T2 obj);
}
```

Nope. That doesn't compile either. "'add(T1)' clashes with 'add(T2)'; Both methods have the same erasure". That's unfortunate. That wasn't even going to be a particularly good solution, since it would lead to proliferating other interfaces like `Report3`, `Report4`, and `ReportX`. Well... What can we do? I guess we could go back to the last idea, and make things even more concrete.

```
public interface CandyReport
{
    void add(Candy candy);
}

public interface EasterEggReport
{
    void add(EasterEgg egg);
}

public class EasterCollectionReport implements CandyReport, EasterEggReport { ... }
```

Finally! We got it to compile. Now CandyReport is interface segregated from EasterEggReport. However, this solution really doesn't feel very satisfying, nor does it appear very scalable. I have a sneaking suspicion that this approach will force us to create a lot of very-specific degenerate interfaces in the future. 

Needless to say, type erasure and generic interfaces don't play nicely together when the goal is to create abstract patterns and problem solutions. There are some ways this can be circumvented, but type erasure certainly is a bit of a minefield. In my next piece I will explain how type erasure negatively impacts Serialization and Representational State Transfer.
