--Onmyō Theocarnation
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon any Spirit Ritual Monster from your hand or GY
	Ritual.AddProcGreater({handler=c,filter=s.ritualfilter,matfilter=s.ritmatfilter,location=LOCATION_HAND|LOCATION_GRAVE})
	--If this card is in your GY or banishment: You can add this card, then if you control a Level 6 or higher Spirit monster and/or 1 "Onmyō Gemsmith Misumaru", add 1 Spirit monster or 1 "Onmyō the Dichromatic Shingyoku" from your Deck or GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_names={81519990,81519994}

function s.ritualfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsRitualMonster()
end

function s.ritmatfilter(c)
	return (c:IsType(TYPE_SPIRIT) or c:IsRace(RACE_ROCK) or c:IsRace(RACE_ILLUSION))
end

function s.thfilter1(c,e,tp)
	return (c:IsLevelAbove(6) and c:IsType(TYPE_SPIRIT) or c:IsCode(81519990))
end

function s.thfilter2(c)
	return (c:IsType(TYPE_SPIRIT) and c:IsMonster() or c:IsCode(81519994)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
	and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end		
	end
end