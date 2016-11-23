# Sharing and mutability in Rust

*(NashFP, 24 November 2015)*

I've mentioned this book before:
*Purely Functional Data Structures*
by Chris Okasaki.

I decided to try implementing the examples in this book
in the Rust programming language.

Now, Rust is *not* a purely functional language.
So why would anyone do this?

Well, Rust has an interesting attitude toward mutability,
and that's what I want to talk about tonight.


## Bits of Rust

### The basics

[Everything is immutable by default.](https://play.rust-lang.org/?gist=a9f4421f2e210776f345)

```rust
fn main() {
    let x = 1;
    x = 2;      // error: re-assignment of immutable variable `x`

    let nums = vec![1, 2, 3];
    nums.push(4);   // error: cannot borrow immutable local variable `nums` as mutable
}
```

You can make a variable mutable using `mut`.
Then you can assign to the variable;
if it's a type that has fields, you can assign to those;
and if it has any mutating methods, [you can call them.](https://play.rust-lang.org/?gist=62fed5a2bfba33f2f810)

```rust
let mut nums = vec![1, 2, 3];
nums.push(4);   // this is OK
```

So where some langauges
have mutable and immutable variants of types
(Python has mutable lists and immutable tuples),
Rust has a single type `Vec`
and your `Vec` can be declared either mutable or immutable.


### Temporary mutability

A `Vec` can be mutable while you're building it,
and then you can return the finished `Vec`
and [the caller can treat it as immutable from then on](https://play.rust-lang.org/?gist=87a702a1f6d2bef26d80).

```rust
fn all_pairs(a: &[i32], b: &[i32]) -> Vec<(i32, i32)> {
    // Build a vector. Note that result is mutable throughout.
    let mut result = Vec::new();
    for &i in a {
        for &j in b {
            result.push((i, j));
        }
    }
    result
}

fn main() {
    // Now we'll call that function, and assign result to a non-mut variable.
    // This makes the Vec immutable! The data is *not* copied;
    // it's the same buffer. But the mutable methods are inaccessible.
    let pairs = all_pairs(&[1, 2, 3], &[1, 4, 9]);
    pairs.push((3, 6));     // error: immutable local variable `pairs`
}
```


### What's being enforced

Maybe this sounds kind of... trivial.
Data is immutable except when you decide you want to mutate it.

But this policy really is enforcing something that matters.

Here's the deal.

**If data is shared, then it's immutable.**
Rust statically tracks references to data.
You can only mutate data if you are the sole owner of that data
and no other direct references to it exist.

So what does this mean?
You know how in JavaScript,
every node in DOM tree has a `ownerDocument` property
that points to the same `Document` object?
This means basically every node in a document has a pointer to every other node in the document,
there's no such thing as an isolated subtree of nodes.
That would not be permitted in Rust,
without climbing through some serious hoops,
because Rust forces you to choose.
You can either have all these pointers, like the DOM;
or you can have mutability.
Take your pick.

In the `all_pairs` example, we're allowed to mutate `result`
because we created it,
and this `result` variable owns it.
No other references exist.

[Let's try an example where that is not the case.](https://play.rust-lang.org/?gist=9f09e02cc26399a3f402&version=stable)

```rust
pub fn main() {
    let mut v = vec![1, 3, 5, 7, 9];
    let favorite_slot = &v[3];
    v.push(11);  // error: `v` is also borrowed as immutable
    println!("my favorite number is {}", *favorite_slot);
}
```

In C++, you can write the same program.
It compiles just fine.
You get undefined behavior.
(Changing the size of a C++ vector invalidates the pointer into it.)

Why does Rust have this policy?
What guarantee do we get out of this?
This example shows a safety benefit
that should have some appeal for C++ survivors.
But there's something else:
**If you have an immutable reference to a value,
the value will not change
across the lifetime of that reference.**

Even if it's a reference to a whole huge subtree of objects.

Even if other threads have a reference to the same data.


### Why purely functional data structures

A consequence of this model is that
Rust's data structures tend not to share any memory.

If you want several trees, or several hash tables, or several vectors,
that all have slightly different versions of the same data,
tough.

`Vec`, for example: no two `Vec`s share memory at all.
If you have a vector and you clone it,
you get a second deep copy of the data.

If somebody passes you an immutable reference to a `Vec`,
say it's a shopping list,
and you want to add a few items,
you must copy the whole list.

So in Rust, if you want data structures that share data,
purely functional data structures are the obvious approach.
(Disclaimer: I'm pretty new at Rust; there may be other ways.)


## OK, for real, purely functional data structures in Rust

### Lists

So let's just look at [a little code.](https://play.rust-lang.org/?gist=0613103e3ba06bd2a166)

```rust
use std::rc::Rc;

pub enum List<T> {
    Nil,
    Cons(Rc<(T, List<T>)>)
}
```

[This code is in a public Github repo you can grab and build.](https://github.com/jorendorff/rust-fundata/blob/master/src/list.rs#L7-L10)

This is my type declaration for purely functional lists in Rust.

What this says is,

*   We're using the `Rc` reference-counting module from the standard library.
    Rust doesn't have garbage collection,
    so my code uses reference counting to manage memory.

*   The type `List<T>` is a public `enum`.

*   A `List` is either `Nil`, or a `Cons`.

*   `Nil` doesn't have any special data associated with it.
    It's just a constant, like an enum in C.

*   `Cons` does:
    a `Cons` is a reference counted pointer to a pair of values,
    the head and tail of a list.


### Pointers in Rust

Compare this to the corresponding Haskell:

```haskell
data List a = Nil
            | Cons (a, List a)
```

It's pretty similar, but Rust requires this extra `Rc`,
because all pointers are explicit in Rust.
In Haskell, and most new programming languages these days,
*everything* is a pointer.
No object physically contains another object.
In `struct`-y languages like Rust,
the default is the opposite:
objects actually nest physically in memory.

So I needed to have this `Rc`, and it makes everything
a bit less elegant and effortless than Haskell.
I had to figure out where to put it.
It's a bit fiddly.


### Sharing and shallow cloning

I gave this type a `clone()` method,
because that is a useful thing to have in Rust,
but my `clone()` method doesn't actually copy the entire list.
It just clones the `Rc`,
which bumps a reference count on already-allocated, immutable data.


### A simple method

To give you a feel for what it's like to
[put a method on a type in Rust:](https://play.rust-lang.org/?gist=84ef78b4a5a53d7a52c3)

```rust
impl<T> for List<T> {
    fn head(&self) -> Option<&T> {
        match _self {
            List::Nil => None,
            List::Cons(ref pp) => Some(&(**pp).0)
        }
    }
}
```

Again, the fact that pointers are explicit
means writing a lot of `*` and `&` and `ref`
that you wouldn't have in any other language.

(For me, the most disappointing thing here
is that pattern matching did not get me
all the way to where I wanted to go.

I would have loved to write

```rust
match *self {
    Nil => None,
    Cons(Rc((ref head, _))) => Some(head)    // error - no such syntax in Rust
}
```

but Rust does not have patterns
that traverse smart-pointer types like `Rc`.)


### The punchline

But the cool thing I wanted to show off here is how easy Rust makes it
to implement purely functional data structures...
[and then mutate them.](https://gist.github.com/jorendorff/fb36f0e2ba7762ef2806)

```rust
impl<T> List<T> {
    fn push_front(&mut self, value: T) {
        let mut tmp = List::Nil;
        std::mem::swap(&mut tmp, self);
        *self = List::Cons(Rc::new((value, tmp)));
    }
}
```

This allows you to write stuff like:

```rust
let mut my_list = List::Nil;
my_list.push_front("world");
my_list.push_front("hello");
```

Maybe there is nothing wrong with mutating a purely functional data structure,
as long as there are no other references to observe the change.


## Conclusion

*   Shared mutable state is a mess.

*   Most programming langauges make no effort to control that mess at all.

*   Functional programming languages mostly help by eliminating mutable state.

*   In Rust, you choose between "shared" and "mutable".

