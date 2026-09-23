--Black Trial Invitation
local s,id=GetID()
function s.initial_effect(c)
	--Banish as many monsters your opponent controls as possible face-down, then you can Special Summon 1 "The Black Goat of the Woods" from your Extra Deck, ignoring its Summoning conditions, then attach 1 "Black Trial" card from your Deck and/or Extra Deck to 1 Rank 12 DARK Xyz Monster you control, and if you do, attach this card to it as additional material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(Cost.PayLP(1/2))
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY, except the turn it was sent there: You can banish this card and 5 "Black Trial" cards from your GY face-down, then target up to 6 cards your opponent controls; banish them face-down, and if you do, inflict 600 damage to your opponent for each card banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.rmvcost)
	e2:SetTarget(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)	
end

s.listed_series={0x421}
s.listed_names={id,13741171}

function s.confilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(s.confilter,nil)==#g
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsCode(13741171) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end

function s.attachfilter(c,tp)
	return c:IsSetCard(0x421) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end

function s.xyzfilter(c,mc,tp)
	return c:IsType(TYPE_XYZ) and c:IsRank(12) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local mc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,mc,tp):GetFirst()
			if not xyzc:IsImmuneToEffect(e) then
				Duel.BreakEffect()
				Duel.Overlay(xyzc,mc)
				xyzc:CompleteProcedure()
				if c:IsRelateToEffect(e) then
					c:CancelToGrave()
					Duel.Overlay(xyzc,c)
				end
			end			
		end
	end
	--You cannot declare attacks for the rest of this turn, except with Rank 12 DARK Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not (c:IsType(TYPE_XYZ) and c:IsRank(12) and c:IsAttribute(ATTRIBUTE_DARK)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end

function s.rmvcostfilter(c)
	return c:IsSetCard(0x421) and c:IsAbleToRemoveAsCost()
end

function s.rmvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.rmvcostfilter,tp,LOCATION_GRAVE,0,5,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmvcostfilter,tp,LOCATION_GRAVE,0,5,5,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end

function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,6,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*600)
end

function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) then tg:AddCard(c) end
	if #tg==0 then return end
	local dam=Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)*600
	if dam>0 then
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
