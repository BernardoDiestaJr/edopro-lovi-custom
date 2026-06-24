-- Worm Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Reptile Fusion Monster, including 1 Reptile monster as material
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=s.mfilter,extrafil=s.fextra,stage2=s.summonlimit})
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)	
	--Set 1 "W Nebula Meteorite", from your hand, Deck or GY.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.settarget)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)	
end

s.listed_names={id,90075978}
s.listed_series={SET_WORM}

function s.mfilter(c)
	return (c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAbleToGrave())
end

function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_REPTILE) 
end

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil),s.checkmat
end

function s.summonlimit(e,tc,tp,mg,chk)
	if chk==2 then
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		--You cannot Special Summon from the Extra Deck for the rest of this turn after this card resolves, except Reptile Monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_REPTILE) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.setfilter(c)
	return c:IsCode(90075978) and c:IsSSetable()
end

function s.settarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end