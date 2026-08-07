--Trinuclear Inheritant Hellraven
local s,id=GetID()
function s.initial_effect(c)
	--You can only Special Summon "Trinuclear Inheritant Hellraven(s)" once per turn
	c:SetSPSummonOnce(id)
	--Special summon itself from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects (but you can only use each effect of "Trinuclear Inheritant Hellraven" once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.PayLP(300))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

s.listed_series={}
s.listed_names={id}

function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,c,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and loc&LOCATION_ONFIELD>0 and Duel.IsChainNegatable(ev)
end

function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(p,LOCATION_SZONE)
		and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden())
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
	local b3=not Duel.HasFlagEffect(tp,id+3)
		and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)	
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DECKDES)
		Duel.RegisterFlagEffect(tp,id+3,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,1,1,nil):GetFirst()
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if op==1 then
		--Target 1 face-up monster on the field; negate its effects, and if you do, destroy it.
		if tc:IsRelateToEffect(e) and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e) then
			--Negate its effects
			tc:NegateEffects(e:GetHandler())
			Duel.AdjustInstantly(tc)
			if tc:IsDisabled() then
				Duel.Destroy(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif op==2 then
		--Target 1 face-up Spell/Trap on the field; negate its effects, and if you do, banish it. 
		if tc:IsRelateToEffect(e) and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e) then
			--Negate its effects
			tc:NegateEffects(e:GetHandler())
			Duel.AdjustInstantly(tc)
			if tc:IsDisabled() then
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif op==3 then
		--Target 1 face-up monster in either GY or banishment; place it face-up in its owner's Spell & Trap Zone as a Continuous Spell, and if you do, send the top card of their Deck to the GY.
		if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
		if tc:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
			Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
		elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
			--Treat it as a Continuous Spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
			tc:RegisterEffect(e1)
		end		
	end
end
