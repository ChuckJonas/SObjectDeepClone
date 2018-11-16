# SObjectDeepClone
A Utility class to Clone and SObject &amp; it's children

## Install

1. `git clone`
2. `cd` into folder
3. `sfdx force:mdapi:deploy -d ./src -w 10000 -u [username]`

## Usage

```java
Lead leadToClone = //...
SObjectDeepClone leadClone = new SObjectDeepClone(
    leadToClone,
    new Set<String>{
        'Tasks'
    };
);
Lead clonedLead = (Lead) leadClone.save();
```