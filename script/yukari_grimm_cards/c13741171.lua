--The Black Goat of the Woods
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon Procedure: 6 DARK Xyz Monsters with the same Rank
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,6,nil,nil,nil,nil,false,s.xyzcheck)
	--Must be Xyz Summoned using the correct materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--xyz summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)	
	--This card gains these effects, based on the number of materials with different names attached to it
	--● 1+: Once per turn, during the Standby Phase: You can attach the top card of either player's Deck to this card as material, then shuffle any number of cards from either GY or banishment into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.effcon(1))
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)		
	--● 2+: Once per turn, during the Main Phase (Quick Effect): You can detach 3 materials from this card, then target 1 DARK Xyz Monster in either GY; this card gains that monster's effects until the End Phase, also other monsters you control cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.AND(
		function()
			return Duel.IsMainPhase()
		end,
		s.effcon(2))
	)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.copytg)
	e3:SetOperation(s.copyop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)	
	--● 6+: It is unaffected by your opponent's monster effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.effcon(6))
	e4:SetValue(function(e,te) return te:IsMonsterEffect() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e4)
end

s.listed_series={}
s.listed_names={id}

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT) end,nil)
	return mg:GetClassCount(Card.GetRank)==1
end

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se
end

function s.sumcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end

function s.effcon(material_count)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetCode)>=material_count
	end
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetDecktopGroup(tp,1)
	local b2=Duel.GetDecktopGroup(1-tp,1)	
	if (b1 or b2) and c:IsRelateToEffect(e) then
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		if op==1 and #b1==1 then
			--Attach the top card of your Deck to this card as material
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,b1)
		elseif op==2 and #b2==1 then
			--Attach the top card of your opponent's Deck to this card as material
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,b2)
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,126,nil)
			if #tdg>0 then
				Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end	
		end
	end	
end

function s.copyfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.copyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,1,nil)
end

function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCodeRule()
		c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
		--Also other monsters you control cannot attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return fid~=c:GetFieldID() end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
