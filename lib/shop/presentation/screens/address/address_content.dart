import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop_app_clean_architecture/core/index.dart';
import 'package:shop_app_clean_architecture/shop/domain/index.dart';
import 'package:shop_app_clean_architecture/shop/presentation/index.dart';
import 'package:shop_app_clean_architecture/utils/index.dart';

class AddressContent extends HookWidget {
  const AddressContent({
    required this.onLongPressed,
    Key? key,
  }) : super(key: key);

  final Function(AddressResponseEntity? chosenAddress) onLongPressed;

  @override
  Widget build(BuildContext context) {
    final addressState = context.watch<AddressCubit>().state;
    final addressCubit = context.read<AddressCubit>();
    final userAddressesList =
        context.watch<AddressCubit>().userAddresses.values.toList();
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
      ),
      resizeToAvoidBottomInset: false,
      body: BlocListener<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state.message != null) {
            R.functions.showToast(
              message: state.message ?? '',
              color: state.toastColor ?? Colors.transparent,
            );
          }
        },
        child: StateHandlingWidget(
          isLoading: _isLoading(addressState, addressCubit),
          hasError: _hasError(addressState, addressCubit),
          onRetryButtonPressed: () => _onRetryButtonPressed(addressCubit),
          successWidget: PaginatedList(
            isLoading: _isLoadingAddresses(addressState),
            isEmpty: userAddressesList.isEmpty,
            controller: scrollController,
            onScrollCallBack: (context) => _onScroll(addressCubit),
            listEmptyTitle: 'No Address saved, Click + to add',
            listEmptyWidget: const Icon(Icons.location_on),
            listChild: CustomAnimatedList(
              products: userAddressesList,
              itemBuilder: (context, index) => AddressWidget(
                address: userAddressesList[index],
                onLongPressed: (address) {
                  onLongPressed.call(userAddressesList[index]);
                  Navigator.of(context).pop();
                },
              ),
              controller: scrollController,
              animationType: AnimationEnum.slide,
            ),
            onEmptyReloadButtonPressed: () =>
                _onRetryButtonPressed(addressCubit),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressModal(context, addressCubit),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isLoading(AddressState addressState, AddressCubit addressCubit) {
    return (addressState is GetAddressLoadingState &&
            addressCubit.userAddresses.isEmpty) ||
        addressState is AddAddressLoadingState;
  }

  bool _hasError(AddressState addressState, AddressCubit addressCubit) {
    return addressState is GetAddressErrorState &&
        addressCubit.userAddresses.isEmpty;
  }

  bool _isLoadingAddresses(AddressState addressState) {
    return addressState is GetAddressLoadingState;
  }

  void _onScroll(AddressCubit addressCubit) {
    final page = addressCubit.currentPage + 1;
    addressCubit.getUserAddresses(page: page);
  }

  void _onRetryButtonPressed(AddressCubit addressCubit) {
    addressCubit.getUserAddresses(page: addressCubit.currentPage);
  }

  void _showAddAddressModal(BuildContext context, AddressCubit addressCubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
          top: 20.0.h,
          left: 20.0.w,
          right: 20.0.w,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddAddressWidget(
          addressCubit: addressCubit,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          topLeft: Radius.circular(30.0),
        ),
      ),
    );
  }
}
