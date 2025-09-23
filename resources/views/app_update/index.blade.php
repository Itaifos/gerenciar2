@extends('layouts.app')

@section('content')


<div>
    <div class="grid grid-cols-1 px-4 pt-6 xl:grid-cols-2 xl:gap-4 dark:bg-gray-900">
        <div class="mb-4 col-span-full xl:mb-2">
            <h1 class="text-xl font-semibold text-gray-900 sm:text-2xl dark:text-white">@lang('menu.appUpdate')</h1>
        </div>
    </div>



    <div class="flex w-full flex-col p-4">
        <div class="p-4 rounded bg-yellow-50 text-yellow-700">
            Updates desativados. O sistema de verificação/licença foi removido.
        </div>
    </div>


</div>


@endsection


@push('scripts')
    
@endpush
