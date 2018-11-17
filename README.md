# SObjectDeepClone

A Utility class to Clone and SObject &amp; it's children

## Install

1. `git clone`
2. `cd` into folder
3. `sfdx force:mdapi:deploy -d ./src -w 10000 -u [username]`

## Usage

```java
Id leadIdToClone = '00Q3A00001Q0wu7';
SObjectDeepClone clone = new SObjectDeepClone(
    leadIdToClone,
    new Set<String>{
        'Tasks'
    }
);
Id clonedLeadId = clone.save();
System.debug(clonedLeadId);
```

## Considerations

- This utility is not currently optimized for cloning multiple objects (My usecase was to replace the Standard Layout `Clone` button)
- Currently limited to 5 relationships (due to SOQL query limit)
- You might need update `SObjectDeepCloneTest` with your own custom object generators to get tests to pass.