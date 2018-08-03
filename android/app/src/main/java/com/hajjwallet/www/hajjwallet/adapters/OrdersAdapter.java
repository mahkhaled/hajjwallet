package com.hajjwallet.www.hajjwallet.adapters;

import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.hajjwallet.www.hajjwallet.R;

public class OrdersAdapter extends RecyclerView.Adapter<OrdersAdapter.OrderViewHolder> {
    final int VIEW_TYPE_READY = 0;
    final int VIEW_TYPE_REMAINING = 1;


    OnItemViewClicked listener;

    public OrdersAdapter(OnItemViewClicked listener) {
        this.listener = listener;
    }

    @Override
    public int getItemViewType(int position) {
        if (position < 2) {
            return VIEW_TYPE_READY;
        }
        return VIEW_TYPE_REMAINING;
    }

    @NonNull
    @Override
    public OrderViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view;
        if (viewType == VIEW_TYPE_REMAINING) {
            view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_active_order, parent, false);
        } else {
            view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_active_order_ready, parent, false);
        }
        return new OrderViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull OrderViewHolder holder, int position) {

    }

    @Override
    public int getItemCount() {
        return 10;
    }

    class OrderViewHolder extends RecyclerView.ViewHolder {
        public OrderViewHolder(final View itemView) {
            super(itemView);
            itemView.findViewById(R.id.iv_map_to_shop).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Uri uri = Uri.parse("geo:21.6195891,39.1501999?q=" + Uri.encode("AlBaik"));
                    Intent intent = new Intent(android.content.Intent.ACTION_VIEW, uri);
                    itemView.getContext().startActivity(intent);
                }
            });
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (listener != null) {
                        listener.onItemCliecked();
                    }
                }
            });
        }
    }

    public interface OnItemViewClicked {
        void onItemCliecked();
    }
}
