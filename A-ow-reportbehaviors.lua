-- name: .Report Behaviors
_ = hook_behavior
--- @param behaviorId BehaviorId | integer?  The behavior id of the object to modify. Pass in as `nil` to create a custom object
--- @param objectList ObjectList | integer Object list
--- @param replaceBehavior boolean Whether or not to completely replace the behavior
--- @param initFunction? fun(obj:Object) Run on object creation
--- @param loopFunction? fun(obj:Object) Run every frame
--- @param behaviorName? string Optional
--- @return BehaviorId BehaviorId Use if creating a custom object, otherwise can be ignored
--- Modify an object's behavior or create a new custom object
_G.hook_behavior = function (behaviorId, objectList, replaceBehavior, initFunction, loopFunction, behaviorName)
    print("Behavior hooked:\n\n"..
          (behaviorId and "Behavior ID: "..tostring(behaviorId) or "No behavior ID").."\n"..
          "Object list: "..tostring(objectList).."\n"..
          "Replace behavior? "..tostring(replaceBehavior).."\n"..
          (behaviorName and "Behavior Name: "..behaviorName or "No behavior name").."\n"
    )
    return _(behaviorId, objectList, replaceBehavior, initFunction, loopFunction, behaviorName)
end