--Windrous Shrine
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Search 1 "Windrous" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Target up to 2 WIND Synchro Monsters in your GY or banishment; place them face-up in their owners' Spell & Trap Zones as Continuous Traps
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)	
	--You can return up to 2 Monster Cards you own from your Spell & Trap Zone to the Extra Deck, then you can Special Summon 1 "Windrous" Synchro Monster from your Extra Deck (this is treated as a Synchro Summon)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetCost(Cost.PayLP(1/4))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end

s.listed_series={0x2f1}
s.listed_names={id}

function s.thcostfilter(c,tp)
	return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.thfilter(c)
	return c:IsSetCard(0x2f1) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--You cannot Special Summon for the rest of this turn, except WIND monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WIND) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.plconfilter(c,tp)
	return c:IsSynchroSummoned() and c:IsFaceup()
end

function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.plconfilter,1,nil,tp)
end

function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsMonster() and c:CheckUniqueOnField(p,LOCATION_SZONE) and not c:IsForbidden()
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		tg=tg:Select(tp,ft,ft,nil)
	end
	for tc in tg:Iter() do
		if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
			--Treat it as a Continuous Spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end

function s.exspfilter(c,e,tp)
	return c:IsSetCard(0x2f1) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local turn_ct=Duel.GetTurnCount()
		--Return it to the Extra Deck during the End Phase of the next turn
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoDeck(ag,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end,function(ag) return Duel.GetTurnCount()==turn_ct+1 end,nil,2,aux.Stringid(id,4))
		tc:CompleteProcedure()
	end
end