---
layout: post
title: Using Probabilistic Forecasting
---


I am a big fan of Lean/Kanban practices for product development. Having used many styles of Agile and Waterfall over the years, I have found that the straight forward prioritized queues and data driven analysis makes life simpler for the team, and makes projections more reliable for the organization.

Of course, there are no 100% gaurantees in software. You may hit something unexpected at any turn. Therefore, time-boxing your releases is generally better than scope-boxing your releases. And, if you want to predict when a feature will be avaialable, better to predict based on your past performance than predict on estimates. Estimates are only guesses, and do not account for the unknowns we run into in software every day.

Forecasting without estimates allows your team to discussion what to build and how to build it without spending time guessing how long it will take. Several companies I have worked for have, not surprisingly, used some implementation of Scrum. When using Scrum, estimation by story points far out performs time estimates. But, why spend your developers time estimating the effort when they could be focused on the problem and implementing a solution?

Saying that the team does not need to estimate the effort is not to say that the team doesn't need to think about the effort at all. Work should still be broken into reasonably sized increments, that the team feels could take between 1-3 days. The goal is entirely different, rather than estimating when the work might be completed, by trying to create relatively equal sized units of work you will reduce the standard deviation and your predictability will be less volatile. Managed this way, the stream of work it is also easier to adapt to change, and you no longer have the overhead of Scrum in moving stories in and out of Sprints. A story is no longer necessary or no longer a priority, simply drop it or stop working on it.

Let's walk through how you can put these types of measurements together.

## Measurements

All the calculations are built from three essential metrics: throughput, cycle time, and work in progress.

* Throughput: Number of items closed per unit of time
* Cycle time: Number of units of time it takes to close one item (from when work starts to when its closed)
* Work In Progress: Number of items in progress

Cycle time and Lead time in software development have been imprecisely applied from the manufacturing world. This can be confusing, so if someone talks about lead time or cycle time, its best to clarify what definitions they are using.

This is the definition I use.

![Cycletime definition](/files/cycletime_def.png){:class="img-responsive-66"}

Additionally, following Little's Law, you can find the average WIP for your team:

**Average WIP = Throughput * Cycletime average**

The Standard Deviation can help show you how volatile the cycle times of your team are. That is are you breaking stories down into similarly sized increments or is there a large deviation between a short (small) story and a long (large) story?

A sample data table looks like this:

| Workdays in period      | 25          |
| Closed in period        | 35          |
| Throughput (Closed/day) | 1.4         |
| Cycletime average       | 4.11        |
| Average WIP             | 5.76        |
| StdDev                  | 3.012084504 |


### Calculating rolling average cycle time

Loading your cycletimes into a spreadsheet (this example using Google Sheets), you can view your team's average cycletime over an average time period. Using Google Sheets QUERY function, you can calculate the average cycle time as follows:

```
=AVERAGE(QUERY({Range}, \
  "SELECT N WHERE H > date '"&TEXT(H2-30, "yyyy-mm-dd")&"' \
  AND H <= date '"&TEXT(H2, "yyyy-mm-dd")&"'", 1))
```

Where:

- Range: The data range to query over, e.g. `A$2:N$50`
- Column N: Cycle time
- Column H: Closed date

The rolling average is specified by subtracting desired period from the close date in column H. The example is using 30 days.

### Calculating Cycle time percentiles

Probabilistic forecasting gives you the ability to predict the likelihood of completing an amount of work based on your team's past performance. Use various percentiles of your cycletimes to calculate the possible chances of completing an amount of work within a period of time.

For example, given a month of cycletimes using the Percentile formula I can see that 95% of the time a unit of work is completed less than 5 days, and 50% of the time it is completed in less than 4.3 days.

| Probability        | 95.00% | 85.00% | 70.00% | 50.00% |
| Cycle time (30-day) | 4.91   | 4.65   | 4.38   | 4.29   |

With these values, we can predict how long it will take the team to finish an amount of work.

```
Total business days = (Total items * average cycle time) / Throughput
```

You can use WORKDAY function to calculate the project end date by percentage.

```
End date = WORKDAY(TODAY(), TotalBusinessDays)
```

Using the average cycletimes in the table above and a team throughput of 1.4 items/day, this would look like:

| Total Issues        | Total Work at 95% | at 85%    | at 70%     | at 50%     |
| 20                  | 98.2              | 93        | 87.6       | 85.8       |
| Total business days | 70.1              | 65.7      | 62.6       | 61.2       |
| End date            | 12/10/2021        | 12/3/2021 | 11/30/2021 | 11/29/2021 |


Another positive here is that this is a whole team metric, not a per individual one.

Now, as a team, you can discuss how to make improvements, either increasing throughput or decreasing cycle time will increase flow through the system. Analysis of your development workflow, such as using a Cumulative Flow diagram, can help surface patterns of inefficiency that block items flowing through your development system. ![CFD Diagram](/files/chart.png)

If you have a product management system (Jira, Gitlab, etc), then you can just pull the team's performance data directly, and calculate a probability forecast. At its simplest, a Kanban workflow contains a prioritized list of work to do, work in progress, and work completed. To expose deeper patterns, your workflow should include the discreet steps. If, for instance, your team uses an asynchronous code review process rather than mobbing, then code review would be another step in your workflow.
