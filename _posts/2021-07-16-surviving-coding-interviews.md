---
layout: post
title: Surviving coding interviews... without the panic!
excerpt: Contrary to what most companies and hiring managers believe, that technical interviews evaluate your ability to program, the coding interview is really testing is your response to stress.
---

![Don't Panic](https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/The_Hitchhiker%27s_Guide_to_the_Galaxy.svg/1200px-The_Hitchhiker%27s_Guide_to_the_Galaxy.svg.png)

Contrary to what most companies and hiring managers believe, technical interviews don't fairly evaluate your ability to program. The coding interview is really testing is your [response to stress](https://www.health.harvard.edu/staying-healthy/understanding-the-stress-response).

More than likely, you can solve any coding challenge you will encounter in an interview. If it is the case that you are thrown a question beyond your capability, then your nerves aren't the barrier to successfully answer the question anyway. The real challenge of the coding interview is combatting your internal anxiety, the [fight-or-flight response](https://www.psychologytools.com/resource/fight-or-flight-response/), that comes from being judged competent enough to gain employment or not. Are you worthy enough to obtain membership into this particular software development team?

This semi-irrational fear can stop you cold. You need to earn money to eat, and put a roof over your head, and how will you provide for your spouse or partner or kids, and how will you save for emergencies, and what about retirement?

And, and, and...

Thoughts spiral out of control pretty quickly. Everything will be okay... as long as you can implement this binary search algorithm in the next 15 minutes, without mistakes, and without sweating enough that this guy in the t-shirt, conspicuously hiding his stare while taking notes, will think you are struggling to answer the question ("I wonder what he's writing about me? I bet he's noting how long it's taking me to start typing. How much time has gone by?").

If you are wired anything like me, this probably sounds all too familiar. This is pretty much how I feel in these situations. The coding interview is one of a handful of encounters that can very quickly cause my brain to completely and utterly shutdown. What starts as a simple coding exercise turns into an existential crisis in about a minute and a half.

So, if your suffer in these situations as I do, what should you do? Quoting the immortal advice of [The Hitchhiker's Guide to the Galaxy](https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#Don't_Panic), Don't Panic!

Actually, that's terrible advice. Telling yourself not to panic will probably make you worry more and panic faster. The key is to turn off your fight or flight response by deploying a coping strategy. In other words, have a plan of action. Then, focus on executing the plan. In yoga, your body will continually go in and out of balance. The key is to continually adjust back to center. In meditation, your mind will wander. The key is to come back to the focal point every time. The same concept applies to managing your stress response during these interview situations. How can you accomplish this when you don't know what question you will be asked? The surprise nature of the questions also adds to the stress of the situation. Here is a simple stragey that helped me, and I hope will help you.

## Steps to manage stress during your coding interview

It's okay to take a few minutes to think through the problem. It's okay to write notes to yourself. Ask clarifying questions, breakdown the problem, and strategize a solution. When you're ready, breathe, and use these simple steps.

1. Explain your approach

2. Write a test for one task

3. Write the code for the test

5. Repeat steps 2 and 3 until done

If your evaluation is in person, memorize the steps, write them in your notebook, and read it as many times as you can before and in-between the interview stages. If you're doing a video interview, write them on a 3x5" note card and tape it to your monitor.

Basically, what I am suggesting here is that you apply [TDD](https://martinfowler.com/bliki/TestDrivenDevelopment.html) to the coding exercise. Identify the goal, write a failing test, write code to make the test pass, and improve the code as you go along, repeat until the problem is done. **When your anxiety peeks** again, and you lose your train of thought, **breathe**, look at your notes, and **reset your focus on the next step!**


> If the interviewer says, "You don't need to write tests for this", consider politely saying, "Thank you for your time. I don't think this is the opportunity for me. Good luck filling your role."

## Practice the steps before the interview

What might this test-driven approach look like in an interview situation? You probably won't have access to your favorite testing library, nor will you have time to setup an ideal environment; the point of the interview is to produce the correct answer within a limited time frame. However, you can create an ad-hoc test environment by using some of the language's features, such as the `assert` function.

Practice using whatever ad-hoc test framework you come up with on some common programming algorithms in the language you will be using in the interview. This way you can design the simplest test approach and get some experience with it. Does it print an error that is easily understandable? Can you quickly compare the `expected` and `actual` output?Remind yourself of the steps throughout your practice:

1. Explain your approach

2. Write one test

3. Write code to pass the test

4. Repeat

This repetition will help you remember the steps when your stress response starts to kick in. When you are in the interview, remind yourself to focus on what needs to be done to complete the next step. The goal of this practice is **not** to improve your coding ability but to **strengthen your ability to regain focus**. Just like practicing yoga or meditation.
