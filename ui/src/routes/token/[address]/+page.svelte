<script lang="ts">
    import Typography from '$lib/components/ui/typography.svelte'
	import { page } from '$app/stores'
    import { ethers } from 'ethers'
    import { FunFun__factory, type FunFun, FunToken__factory, type FunToken } from '$lib/typechain'
	import { onMount } from 'svelte'

    // eslint-disable-next-line svelte/valid-compile
    const address = $page.params.address
    let state: any = $state(undefined)

    onMount(() => token())

    async function token() {
        const funContract = new ethers.Contract(address, FunFun__factory.abi) as unknown as FunFun;
        console.debug({ funContract })
        const maxSupply = await funContract.maxSupply()
        const raiseTarget = await funContract.raiseTarget()
        const endsAt = await funContract.endsAt()
        const funToken = await funContract.funToken()
        const funTokenContract = new ethers.Contract(funToken, FunToken__factory.abi) as unknown as FunToken;
        const totalSupply = await funTokenContract.totalSupply()
        state = {
            maxSupply,
            raiseTarget,
            endsAt,
            totalSupply,
        }        
    }

</script>

<div class="spacer"></div>
<div class="spacer"></div>
<div class="spacer"></div>
<div class="spacer"></div>

<img src="/FUNraising_transparent.png" alt="logo"/>
<pre>
    {JSON.stringify(state, undefined, 4)}
</pre>

<style>
    img {
        width: 384px;
        height: 384px;
        margin-bottom: 24px;
    }
    .spacer {
        margin-bottom: var(--padding);
    }
    :global(.margin-top) {
        margin-top: 24px;
    }
</style>