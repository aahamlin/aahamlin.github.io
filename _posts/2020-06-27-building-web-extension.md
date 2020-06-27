---
layout: post
title: Building a web extension
---

The past couple weeks I have built a [browser extension](https://github.com/aahamlin/stoptrackingme-extension) to block tracking services and cookies.

Beyond exploring the Disconnect tracking protection data and techniques, such as Tracking pixels and Fingerprinting, this was an opportunity to work with ES modules, the Mocha/Chai/Sinon Javascript test frameworks, and SVG in Elm.

Once loaded into Chrome, the Stop Tracking Me extension is available in the Manage Extensions page.

![Extension](/files/stoptrackingme/stoptrackingme-ext.png){:class="img-responsive-66 img-shadow"}

The blocking activity is displayed per tab on the browser toolbar. By clicking on the Stop Tracking Me icon \(the bear tracks\), a summary of the past 7 days activity by cateogry will be displayed.

![toolbar ui](/files/stoptrackingme/toolbar-badge-ui.png){:class="img-responsive-66 img-shadow"}

![popup ui](/files/stoptrackingme/popup-ui.png){:class="img-shadow"}

A number of things are left undone in the extension, primarily because this was just meant as an exercise to learn. All times are in UTC only. Trackers that contained in content scripts served from a first-party url will not be blocked, as I did not implement a content script in the extension. The history of events is stored in the extension local storage which has a 5MB limit, there is no checking for or handling of size should it exceed the limit. It is not possible to whitelist sites or allow third-party cookies, so visiting an online vendor that uses a third-party shopping cart will most likely fail to function properly.
