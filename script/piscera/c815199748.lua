--Paleozoic Piscera Hexaseas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate 1 "Paleozoic" or "Piscera" Trap Card the turn it was Set.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PALEOZOIC))
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1fe))
	c:RegisterEffect(e3)
	--Xyz Summon using only "Paleozoic" and "Piscera" monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE|LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetCost(Cost.SelfBanish)	
	e4:SetTarget(s.xyztg1)
	e4:SetOperation(s.xyzop1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetTarget(s.xyztg2)
	e5:SetOperation(s.xyzop2)
	c:RegisterEffect(e5)	
	--Search 1 Level 3 EARTH Tuner monster from your Deck, or if you control a non-Effect Monster, you can Special Summon it instead.
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.thspcon)
	e6:SetTarget(s.thsptg)
	e6:SetOperation(s.thspop)
	c:RegisterEffect(e6)
	--Its name becomes "Umi"
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CHANGE_CODE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetValue(CARD_UMI)
	c:RegisterEffect(e7)	
	
end

s.listed_series={0x1fe,SET_PALEOZOIC}
s.listed_names={id,815199749}

function s.xyzfilter(c,mg)
	return ((c:IsSetCard(SET_PALEOZOIC) and c:IsMonster()) or c:IsSetCard(0x1fe) and c:IsMonster()) and c:IsXyzSummonable(nil,mg)
end

function s.xyztg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x1fe),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #mg>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyztg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PALEOZOIC),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #mg>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop1(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x1fe),tp,LOCATION_MZONE,0,nil)
	if #mg==0 then return end
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,sc,nil,mg)
	end
end

function s.xyzop2(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PALEOZOIC),tp,LOCATION_MZONE,0,nil)
	if #mg==0 then return end
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,sc,nil,mg)
	end
end

function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT+REASON_DISCARD)==REASON_EFFECT+REASON_DISCARD
end

function s.thspfilter(c,e,tp,sp_check)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_TUNER) and c:IsLevelBelow(3) and c:IsMonster()
		and (c:IsAbleToHand() or (sp_check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sp_check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sp_check)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local sp_check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	local desc=sp_check and aux.Stringid(id,3) or HINTMSG_ATOHAND
	Duel.Hint(HINT_SELECTMSG,tp,desc)
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_check):GetFirst()
	if not sc then return end
	if sp_check then
		aux.ToHandOrElse(sc,tp,
			function()
				return sp_check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,4)
		)
	else
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end