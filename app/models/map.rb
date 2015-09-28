require 'json'

class Map < ActiveRecord::Base
    # Relationships
    belongs_to :convention
    has_many :booths

    # Validations

    # Scopes

    # Methods




    # -------------------------
    # Mapcrafter methods (mapMaker.js related)
    # SAVING ORDER OF MODELS: Map, Vendor, Tag, Booth, Vendor_tag, Vendor_booth
    # SAVING ORDER OF ACTIONS: Create, Update, Delete

    # Temp Obj = Object that has never been saved to backend, is new

    # Takes an array of hashes (originally JSON) and saves to map instance and related objects
    def saveFromHistory(jsonActionHistory)
        categorizedHistory = organizeHistory(JSON.parse(jsonActionHistory))

        saveForModel("map", categorizedHistory)
        saveForModel("vendor", categorizedHistory)
        saveForModel("tag", categorizedHistory)
        saveForModel("vendor_tag", categorizedHistory)
        saveForModel("booth", categorizedHistory)
    end

    # Takes array of hashes and organizes in types of actions so that we can save efficiently & properly
    # EX STRUCTURE: { "booth" : {"create" : { "id" : {"x_pos" : 10, ...}, "id" : {...} },
    #                            "update" : { "id" : {...}, "id" : {...} }, ... }
    #                "vendor" : {"create" : { "id" : {...}, "id" : {...} } } ... } ... }
    def organizeHistory(orderedHistory)
        categorizedHistory = {}

        for historyItem in orderedHistory

            # Initializing basic structure
            if categorizedHistory.has_key?(historyItem["type"])
                if categorizedHistory[historyItem["type"]].has_key?(historyItem["action"]) == false
                    # Need to create the action hash for this history item
                    categorizedHistory[historyItem["type"]][historyItem["action"]] = {}
                end
            else # Need to create both the type key and action hash value for it
                categorizedHistory[historyItem["type"]] = {}
                categorizedHistory[historyItem["type"]][historyItem["action"]] = {}
            end

            # Adding into right category, or updating/deleting as necessary
            case historyItem["action"]
            when "create"
                categorizedHistory[historyItem["type"]][historyItem["action"]][historyItem["id"]] = historyItem
            when "update"
                if historyItem.has_key?("isTemp") and historyItem["isTemp"] == true
                    # Instead of creating then updating, just update the create action for the temp obj
                    categorizedHistory[historyItem["type"]]["create"][historyItem["id"]] = historyItem
                else
                    # Updating a previously SAVED obj
                    categorizedHistory[historyItem["type"]][historyItem["action"]][historyItem["id"]] = historyItem
                end
            when "delete"
                if historyItem.has_key?("isTemp") and historyItem["isTemp"] == true
                    byebug
                    # Instead of creating then deleting, just remove the create action for the temp obj
                    categorizedHistory[historyItem["type"]]["create"].delete(historyItem["id"])
                else
                    # Deleting a previously SAVED obj
                    categorizedHistory[historyItem["type"]][historyItem["action"]][historyItem["id"]] = historyItem
                end
            end

        end
        return categorizedHistory
    end

    # Takes in model name and action hash (e.g. {"create" : {...}, "update" : {...}) and does actions
    def saveForModel(modelName, categorizedHistory)
        if categorizedHistory.has_key?(modelName)
            actionHistory = categorizedHistory[modelName]
            createModels(modelName, actionHistory)
            updateModels(modelName, actionHistory)
            deleteModels(modelName, actionHistory)
        end
    end

    # All creates are working off TEMP objs
    def createModels(modelName, actionHistory)
        createActions = if actionHistory["create"].nil? then {} else actionHistory["create"] end
        for idKey in createActions.keys
            createAction = createActions[idKey]
            case modelName
            when "map"
            when "vendor"
            when "tag"
            when "vendor_tag"
            when "booth"
                Booth.create({x_pos: createAction["x"].to_i, y_pos: createAction["y"].to_i, 
                    width: createAction["width"].to_i, height: createAction["height"].to_i, map_id: self.id})
            end
        end
    end

    # All updates working off of SAVED objs
    def updateModels(modelName, actionHistory)
        updateActions = if actionHistory["update"].nil? then [] else actionHistory["update"] end
        for updateAction in updateActions
            case modelName
            when "map"
            when "vendor"
            when "tag"
            when "vendor_tag"
            when "booth"
            end
        end
    end

    # All deletes are working off of SAVED objs
    def deleteModels(modelName, actionHistory)
        deleteActions = if actionHistory["delete"].nil? then {} else actionHistory["delete"] end
        for idKey in deleteActions.keys
            deleteAction = deleteActions[idKey]
            case modelName
            when "map"
            when "vendor"
            when "tag"
            when "vendor_tag"
            when "booth"
                Booth.find(deleteAction["id"]).destroy
            end
        end
    end






end
