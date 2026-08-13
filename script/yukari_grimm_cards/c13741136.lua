--Vicious Rank-Up-Magic Curtain Love Call
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--A Rank 6 or higher Xyz Monster that has this card as material gains this effect
	--● Negate the activation, then you can banish (face-down) 1 card from your opponent's hand or field (the card in the hand is chosen at random)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.xmatcon)
	e1:SetCost(Cost.DetachFromSelf(2))
	e1:SetTarget(s.xmattg)
	e1:SetOperation(s.xmatop)
	c:RegisterEffect(e1)

end

s.listed_series={0x41e}
s.listed_names={id}

function s.xyzfilter(c,e)
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.filter1(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and (rk>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+2,pg)
end

function s.filter2(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsRank(rk) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsRace(mc:GetRace(c,SUMMON_TYPE_XYZ,tp)) and c:IsAttribute(mc:GetAttribute(c,SUMMON_TYPE_XYZ,tp)) and mc:IsCanBeXyzMaterial(c,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,e):GetMaxGroup(Card.GetRank)
	g=g and g:Filter(s.filter1,nil,e,tp) or Group.CreateGroup()
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2,pg)
	local xyz=g:GetFirst()
	if xyz then
		xyz:SetMaterial(tc)
		Duel.Overlay(xyz,tc)
		if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		xyz:CompleteProcedure()
		local c=e:GetHandler()
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				Duel.Overlay(xyz,c)
			end		
		end
	end
end

function s.xmatcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return (c:IsRankAbove(6) and c:IsXyzMonster()) and ep==1-tp and re:IsMonsterEffect()
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND and Duel.IsChainNegatable(ev)
end

function s.xmattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND|LOCATION_ONFIELD)
end

function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND|LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_HAND|LOCATION_ONFIELD,1,1,nil)
			if #rg>0 then
				Duel.HintSelection(rg)
				Duel.BreakEffect()
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
	end
end
