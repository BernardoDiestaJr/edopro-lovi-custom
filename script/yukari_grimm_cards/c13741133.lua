--Vicious Theatre - Beast of Purity
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--While this card is in your Pendulum Zone, if you control 3 or more "Vicious Theatre" monsters, your "Vicious Theatre" Xyz Monsters are unaffected by your opponent's Spell effects.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x41e),tp,LOCATION_MZONE,0,3,nil) end)
	e0:SetTarget(s.etarget)
	e0:SetOperation(s.efilter)
	c:RegisterEffect(e0)	
	--If you control a Level/Rank 3 monster, except "Vicious Theatre of the Purified Beast": You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)	
	--Add 1 Level 3 "Vicious Theatre" monster from your Deck or GY to your hand, or if you control "Vicious Theatre Waxwork", you can Special Summon it instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thsptg)
	e2:SetOperation(s.thspop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)	
end

s.listed_series={0x41e}
s.listed_names={id,13741135}

function s.etarget(e,c)
	return c:IsSetCard(0x41e) 
end

function s.efilter(e,re)
	return re:IsSpellEffect() and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.selfspconfilter(c)
	return c:IsFaceup() and (c:IsLevel(3) or c:IsLink(3)) and not c:IsCode(id)
end

function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.selfspconfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.thspfilter(c,e,tp,sp_check)
	return c:IsLevel(3) and c:IsSetCard(0x41e) and c:IsMonster() and (c:IsAbleToHand() or (sp_check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
	local sp_check=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,13741135),tp,LOCATION_ONFIELD,0,1,nil)
	return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,sp_check) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local sp_check=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,13741135),tp,LOCATION_ONFIELD,0,1,nil)	
	local desc=sp_check and aux.Stringid(id,2) or HINTMSG_ATOHAND	
	Duel.Hint(HINT_SELECTMSG,tp,desc)
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,sp_check):GetFirst()
	if not sc then return end
	if sp_check then
		aux.ToHandOrElse(sc,tp,
			function()
				return sp_check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,3)
		)
	else
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end