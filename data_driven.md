# Example of data-driven changes

Here is some abridged analysis and results from data-driven process changes I have delivered.

Using the cycletime command from my [qjira](https://github.com/aahamlin/jira_reporting_scripts) project, I analyzed the cycle time of delivering new features and found that only 25% of new features were completed in a 2-week sprint. 
![Cycle time analysis](/files/cycletime.png)

Further break down of the stages of the development workflow identified specific bottlenecks which where then addressed. One example is a stage before work was handed off to QA, where 25% of the items lingered for more than a week. After addressing this stage, we saw a 10% reduction in items left for longer than a week.
![Work complete times](/files/workcomplete.png)

Before making these process changes sprint velocity was erratic. I measured the difference between our time estimates and actuals using mean absolute percentage error (MAPE). Our sprint planning effectiveness yielded a **70% MAPE**. 
![Velocity before changes](/files/velocity-v1200.png)

After the cycletime analysis and addressing specific bottlenecks, our ability to plan a sprint increased dramatically and yielded a **29% MAPE**.
![Velocity after changes](/files/velocity-v1210.png)
