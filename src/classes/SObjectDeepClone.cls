// Author Charlie Jonas (charlie@callaway.cloud)
// Class to clone an SObject and it's children.
//   - Not currently optimized for bulk use!
//   See https://github.com/ChuckJonas/SObjectDeepClone for readme
public with sharing class SObjectDeepClone {
	private ChildRelationship[] relations;
    private SObjectType type;

    public SObject thisObject;

    public SObjectDeepClone(Id toCloneId, Set<String> relationshipsToClone) {
        type = toCloneId.getSObjectType();
        relations = new ChildRelationship[]{};

        Map<String, ChildRelationship> childRelationMap = new Map<String, ChildRelationship>();
        for(ChildRelationship rel : type.getDescribe().getChildRelationships()){
            childRelationMap.put(rel.getRelationshipName(), rel);
        }

        for(String s : relationshipsToClone){
            if(childRelationMap.containsKey(s)){
                relations.add(childRelationMap.get(s));
            }else{
                throw new DeepCloneException(
                    'Child Relationship \'' + s + '\' does not exsist on ' + type.getDescribe().getName()
                );
            }
        }

        this.relations = relations;
        thisObject = getSObject(toCloneId);
	}

    public SObject save(){
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();

        SObject clone;
        try {
            clone = thisObject.clone(false);
            insert clone;

            for(ChildRelationship rel : relations){
                SObject[] clonedChildren = clone.getSObjects(rel.getRelationshipName());
                clonedChildren.clear();
                for(Sobject child : thisObject.getSObjects(rel.getRelationshipName())){
                    SObject childClone = child.clone(false);
                    childClone.put(rel.getField(), clone.Id);
                    clonedChildren.add(childClone);
                }
                insert clonedChildren;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }

        return clone;
    }

    private SObject getSObject(Id toCloneId){
        // Get a map of field name and field token
        String[] selectFields = getCreatableFields(type);

        //subqueries
        for(ChildRelationship relation : this.Relations){
            SObjectType relationType = relation.getChildSObject();
            String[] relationFields = getCreatableFields(relationType);
            String relationName = relation.getRelationshipName();
            if(relationFields.size() > 0){
                selectFields.add('(' + buildQuery(relationFields, relationName, null) + ')');
            }
        }

        String qry = buildQuery(
            selectFields,
            type.getDescribe().getName(),
            'ID = \''+String.escapeSingleQuotes(toCloneId)+'\''
        );

        System.debug(qry);

        return (SObject) Database.query(qry);
    }

    private string buildQuery(String[] fields, String fromObj, string whereClause){
        String qry = 'SELECT ' + String.join(fields, ',') + ' FROM ' + fromObj;
        if(!String.isEmpty(whereClause)){
            qry += ' WHERE ' + whereClause;
        }
        return qry;
    }

    private String[] getCreatableFields(SObjectType objType){
        DescribeSObjectResult describe = objType.getDescribe();

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = describe.Fields.getMap();
        String[] selectFields = new String[]{};

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        return selectFields;
    }

    public class DeepCloneException extends Exception {}
}