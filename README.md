# SObjectDeepClone

A Apex Utility class to Clone a Salesforce SObject &amp; and it's children.

## Install

1. `git clone`
2. `cd` into folder
3. `sfdx force:mdapi:deploy -d ./src -w 10000 -u [username]`

## Usage

1: Initialize `SObjectDeepClone` with:

- `Id` of the SObject you want to clone.  For more control you can pass the SObject itself

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

By default, all `createable` fields on the parent and target child relationships are cloned.  If you need more control over what is cloned, you can instead pass in the actual `SObject` instance to clone (you're responsible for ensuring all data is present).

## Considerations

- This utility is [not currently optimized for cloning multiple objects](https://github.com/ChuckJonas/SObjectDeepClone/issues/1) (My use-case was to replace the Standard Layout `Clone` button)
- [Currently limited to 5 relationships](https://github.com/ChuckJonas/SObjectDeepClone/issues/2) (due to SOQL query limit)
- Because we must run DML to properly test, you might need update [`SObjectDeepCloneTest`](https://github.com/ChuckJonas/SObjectDeepClone/blob/master/src/classes/SObjectDeepCloneTests.cls#L45) with your own custom object generators to get tests to pass.
