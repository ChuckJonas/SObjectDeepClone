# SObjectDeepClone

A Apex Utility class to Clone a Salesforce SObject &amp; and it's children.

## Install

1. `git clone`
2. `cd` into folder
3. `sfdx force:mdapi:deploy -d ./src -w 10000 -u [username]`

## Usage

1: Initialize `SObjectDeepClone` with:

- `Id` of the SObject you want to clone

- `Set<String>` of any child relationships you want to clone

2. (Optional) make modifications to `.clone`

3. Call `save()`. Returns Id of cloned record

**Example:**

```java
Id leadIdToClone = '00Q3A00001Q0wu7';
SObjectDeepClone cloner = new SObjectDeepClone(
    leadIdToClone,
    new Set<String>{
        'Tasks',
	'Events'
    }
);
Lead beforeClone = (Lead) cloner.clone;
beforeClone.LastName = beforeClone.LastName + ' Copy';
Id clonedLeadId = cloner.save();

System.debug(clonedLeadId);
```

## Considerations

- It automatically clones all `createable` fields on both the parent and children objects (should be made [configurable in future](https://github.com/ChuckJonas/SObjectDeepClone/issues/3)). 
- This utility is [not currently optimized for cloning multiple objects](https://github.com/ChuckJonas/SObjectDeepClone/issues/1) (My use-case was to replace the Standard Layout `Clone` button)
- [Currently limited to 5 relationships](https://github.com/ChuckJonas/SObjectDeepClone/issues/2) (due to SOQL query limit)
- You might need update [`SObjectDeepCloneTest`](https://github.com/ChuckJonas/SObjectDeepClone/blob/d9ed004841f13ba3adaf71a755b20dc61a634c1a/src/classes/SObjectDeepCloneTests.cls#L45) with your own custom object generators to get tests to pass (unforuntely we have to run actual DML to properly test).
