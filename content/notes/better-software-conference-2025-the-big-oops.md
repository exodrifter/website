---
title: "The Big OOPs: Anatomy of a Thirty-five-year Mistake"
created: 2025-07-21T01:28:23-07:00
modified: 2025-07-21T16:59:31-07:00
aliases:
  - "The Big OOPs: Anatomy of a Thirty-five-year Mistake"
tags:
  - better-software-conference
  - object-oriented-programming
---

# The Big OOPs: Anatomy of a Thirty-five-year Mistake

**The Big OOPs: Anatomy of a Thirty-five-year Mistake** was a talk given by Casey Muratori at [Better Software Conference 2025](../notes/better-software-conference-2025.md). [^1] In the talk, Casey makes the claim that OOP was originally motivated by a desire to directly model distributed domains and to improve code reuse. [^2] [^4]

OOP was attractive to developers who were working on distributed systems like Simula, developed by Kristen Nygaard and Ole-Johan Dahl at the Norwegian Computing Center in 1962. [^5] However, Simula ran into a lot of usability problems, including long build times and a slow runtime. [^3]

The Simula developer were inspired by the 1966 paper *Record Handling* by C.A.R. Hoare who suggested the idea of representing classes of objects in the real world with mutually exclusive subclasses and record class discriminators. [^6] Casey also implies that the idea of having discriminated unions was lost at this point because no one believed in it, but I don't agree with this because ML, a language that I believe had this feature, was introduced several years later. [^10]

C.A.R. Hoare was influenced by the idea of a "plex" record-like structure that Douglas T. Ross had previously worked on when they were sitting together on the Algol 68 committee. Douglas T. Ross was working at MIT Servomechanisms Laboratory in Cambridge, MA in 1952 when he had the idea of "plex" structures as a alternate way to design structures, in response to how Lisp could only deal with structures containing at most two elements. While he was working at MIT Servomechanisms Laboratory, a person named Ivan Sutherland starts working there and develops a drawing called Sketchpad. [^7]

Sketchpad had ECS-like design in 1963, but it was overlooked as developers at the time preferred virtual functions and inheritance. We didn't see this kind of system again until a ECS-like system was implemented at Looking Glass by Marc "Mahk" LeBlanc for Thief in 1998. This accounts for the 35-year gap from which this talk gets its name. [^8] [^9]

[^1]: [20250720211327](../entries/20250720211327.md)
[^2]: [20250720230206](../entries/20250720230206.md)
[^3]: [20250720231259](../entries/20250720231259.md)
[^4]: [20250720234626](../entries/20250720234626.md)
[^5]: [20250721043919](../entries/20250721043919.md)
[^6]: [20250721045519](../entries/20250721045519.md)
[^7]: [20250721053713](../entries/20250721053713.md)
[^8]: [20250720220153](../entries/20250720220153.md)
[^9]: [20250721084856](../entries/20250721084856.md)
[^10]: [20250721234527](../entries/20250721234527.md)