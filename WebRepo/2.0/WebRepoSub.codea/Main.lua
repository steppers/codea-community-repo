-- WebRepoSub

function setup()
    
    -- Project Submission workflow
    local metadata = {
        name = "WebRepo",
        short_description = "Codea Community Repository",
        description = "Providing easy access to projects from the community!",
        authors = {
            "Steppers"
        },
        version = "2.0",
        update_notes = " - No release notes.",
        library = false,
        hidden = true,
        review = false,
        icon = "WebRepo.codea/Icon@2x.png",
        -- key = "***"
    }
    
    Submission.submitProject("WebRepoSub", metadata, function(success)
        print((success and "Submitted!") or "Failed to submit!")
    end)
end

function draw()
    background(40, 40, 50)
end

