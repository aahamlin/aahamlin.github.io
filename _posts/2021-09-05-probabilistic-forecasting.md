---
layout: post
title: Using Probabilistic Forecasting
---

My first experience with Kanban was in 2012 or 2013 when, as manager of a sustaining engineering team, I needed to organize software delivery against internal SLAs. We were responsible for resolving Support issues escalated to Engineering. The time frames and priorities changed daily, if not hourly. Managing via Scrum with sprints was simply not adaptive enough. I found a [great primer](https://www.infoq.com/minibooks/priming-kanban-jesper-boeg/) from Jesper Boeg on Kanban and over a month or so reinvented our development process. The turn around was dramatic and the team wonderfully successful.

Ever since, I have been a big fan of Lean/Kanban practices for product development. I have found that the straight forward prioritized queues and data driven process improvements makes life simpler for the team, and makes projections more reliable for the organization.

## Forecasting versus estimating

Of course, there are no 100% guarantees in software. You may hit something unexpected at any turn. Therefore, time-boxing your releases is generally better than scope-boxing your releases. And, if you want to predict when a feature will be available, better to predict based on your past performance than predict on estimates. Estimates are only guesses, and do not account for the unknowns we run into in software every day.

Forecasting without estimates allows your team to discuss what to build and how to build it, without spending time guessing how long it will take. Several companies I have worked for have (not surprisingly) used some implementation of Scrum. When using Scrum, estimation by story points far out performs time estimates. But, why spend your developers time estimating the effort when they could be focused on the problem and implementing a solution?

Saying that the team does not need to estimate the effort is not to say that the team doesn't need to think about the effort at all. Work should still be broken into reasonably sized increments; what the team feels could take between 1-3 days, for example. The goal is entirely different than speculating when the work might be completed. By creating relatively equal sized units of work you will reduce the standard deviation and your predictability will be less volatile. Managed this way, the stream of work it is also easier to adapt to change, and you no longer have the overhead of Scrum in moving stories in and out of Sprints. A story is no longer necessary or no longer a priority, simply drop it or stop working on it.

**How does this work?**

If you don't estimate, how can you ever tell how long a (set of) change(s) will take?

First, measure the flow of changes through your system. Then, use your past performance to calculate (predict) your future performance.

Let's walk through how you can put these types of measurements together.

## Measurements

All the calculations are built from three essential metrics: throughput, cycle time, and work in progress (WIP). It's also useful to measure average WIP and the standard deviation.

* **Throughput**: Number of items closed per unit of time
* **Cycle time**: Amount of time it takes to close one item (from when work starts to when its closed)
* **WIP**: Number of items in progress

You can find the average WIP for your team: **Average WIP = Throughput * Cycle time average**

Standard Deviation can help show you how volatile the cycle times of your team are. That is are you breaking stories down into similarly sized increments or is there a large deviation between a short (small) story and a long (large) story?

A sample data table looks like this:

| Workdays in period      | 25          |
| Closed in period        | 35          |
| Throughput (Closed/day) | 1.4         |
| Cycle time average       | 4.11        |
| Average WIP             | 5.76        |
| StdDev                  | 3.012084504 |

Cycle time and Lead time in software development have been applied from the manufacturing world. The definitions of these terms used in software vary widely. This can be confusing, so if someone talks about lead time or cycle time, its best to clarify what definitions they are using.

This is the definition I am using:

![Cycle time definition](/files/cycletime_def.png){:class="img-responsive-66"}

### Calculating rolling average cycle time

Loading your cycle times into a spreadsheet (this example using Google Sheets), you can view your team's average cycle time over an average time period. Using Google Sheets QUERY function, you can calculate the average cycle time as follows:

```
=IFERROR(AVERAGE(QUERY($A$2:$B$21, \
  "SELECT B WHERE A > date '"&TEXT(A2-10, "yyyy-mm-dd")&"' \
  AND A <= date '"&TEXT(A2, "yyyy-mm-dd")&"'", 1)), B2)
```

Where:

- Range: The data range to query over, e.g. `$A$2:$N$50`
- Column N: Cycle time
- Column H: Closed date

Important notes:

- The Range value should be static ($A$2:$B:$21) while the cells should be dynamically referenced (A2, B2) to propagate the formula correctly.
- The rolling average is specified by subtracting desired period from the close date in column H. The example is using 30 days.
- If the QUERY function returns a single cell, the AVERAGE formula will fail, therefore IFERROR simply returns the single cell.

### Calculating Cycle time percentiles

Probabilistic forecasting gives you the ability to predict the likelihood of completing an amount of work based on your team's past performance. Use various percentiles of your cycle times to calculate the possible chances of completing an amount of work within a period of time.

For example, given a month of cycle times using the Percentile formula I can see that 95% of the time a unit of work is completed less than 5 days, and 50% of the time it is completed in less than 4.3 days.

| Probability        | 95.00% | 85.00% | 70.00% | 50.00% |
| Cycle time (30-day) | 4.91   | 4.65   | 4.38   | 4.29   |

With these values, we can predict how long it will take the team to finish an amount of work.

`Total business days = (Total items * average cycle time) / Throughput`

Using the average cycle times in the table above and a team throughput of 1.4 items/day, the result looks like this:

| Total Issues        | Total Work at 95% | at 85%    | at 70%     | at 50%     |
| 20                  | 98.2              | 93        | 87.6       | 85.8       |
| Total business days | 70.1              | 65.7      | 62.6       | 61.2       |


You can use WORKDAY function to calculate the project end date by percentage.

`Completion date = WORKDAY(TODAY(), TotalBusinessDays)`

| Probability | at 95%     | at 85%    | at 70%     | at 50%     |
| End date    | 12/10/2021 | 12/3/2021 | 11/30/2021 | 11/29/2021 |


Another positive here is that this is a whole team metric, not a per individual one.

## Visualizing and analysis of flow

As a team, you can discuss how to make improvements, either increasing throughput or decreasing cycle time will increase flow through the system. Analysis of your development workflow, such as using a Cumulative Flow and Scatter plot diagrams, can help surface patterns of inefficiency that block items flowing through your development system.

This measurement and improvement of flow is based on [Little's Law](https://en.wikipedia.org/wiki/Little%27s_law). You can find a lot online about Little's Law. The math is pretty simple. By limiting WIP, you can decrease the cycle time and increase the throughput. A great visual demonstration of this is on YouTube created by Michel Grootjans, [Explaining team flow](https://www.youtube.com/watch?v=bhpQKA9XYcE).

Here's a sample set of diagrams that I find useful when looking for patterns and ways to improve flow.

![CFD Diagram](/files/chart.png)

![Cycle time scatter plot](/files/scatterplot.png)

![Histogram](/files/histogram.png)

_The graphs are just examples and are not related to the above example data._

If you have a product management system (Jira, GitLab, etc), then you can just pull the team's performance data directly, and calculate a probability forecast. At its simplest, a Kanban workflow contains a prioritized list of work to do, work in progress, and work completed. To expose deeper patterns, your workflow should include the discreet steps. If, for instance, your team uses an asynchronous code review process rather than mobbing, then code review would be another step in your workflow.
