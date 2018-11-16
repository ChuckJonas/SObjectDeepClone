# SObjectDeepClone
A Utility class to Clone and SObject &amp; it's children

## Install

1. `git clone`
2. `cd` into folder
3. `sfdx force:mdapi:deploy -d ./src -w 10000 -u [username]`

## Usage

```java
Id leadIdToClone = '001232000000123'
SObjectDeepClone leadClone = new SObjectDeepClone(
    leadIdToClone,
    new Set<String>{
        'Tasks'
    };
);
Lead clonedLead = (Lead) leadClone.save();
```