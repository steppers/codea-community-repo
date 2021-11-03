GameOver = {}

function GameOver.init()
    message2 = "The rebels will return"
    if score < 1500 then
        message2 = "The rebellion has been crushed"
    elseif score >= 3000 then
        message2 = "The Empire has been dealt a blow!\n1977 mode unlocked"
        retromode = true
    end
    local seconds = math.floor(ElapsedTime - gameStart)
    local bonus = seconds * 5
    message = string.format("Score: %.6d\nSurvival bonus: %.4d seconds x 5 = %.6d\nTotal score: %.6d", score, seconds, bonus, score + bonus)
    score = score + bonus
    if score > hiscore then
        message = message..string.format("\n\nYou beat your old high score!\n\nOld high score: %.5d\nNew high score: %.5d", hiscore, score)
        hiscore = score
        saveLocalData("hiscore", hiscore)
    end

    timer = ElapsedTime + 1
    scene = GameOver
end

function GameOver.draw()
    Game.draw()
    textMode(CENTER)
    textAlign(CENTER)
    fontSize(60)
    fill(0, 152, 255, 211)
    text(message2, WIDTH*0.5, HEIGHT*0.75)
    fontSize(30)
    text(message, WIDTH*0.5, HEIGHT*0.5)
    if ElapsedTime > timer then
        fontSize(20)
        fill(120)
        text("Tap to restart", WIDTH/2, HEIGHT * 0.2)
    end
end

function GameOver.touched(t)
    if t.state == BEGAN and ElapsedTime > timer then
        Game.init(retromode)
    end
end
